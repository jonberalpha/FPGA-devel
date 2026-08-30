/*
 * QSPI flash writer for the Zybo Z7-20's onboard S25FL128S (16MB) flash.
 *
 * Reads TARGET.BIN from the SD card's FAT filesystem and writes it into
 * QSPI flash sector by sector, verifying each sector by reading it back
 * immediately after writing. Once this has run successfully, set JP5 to
 * QSPI and power-cycle -- the board then boots standalone, no SD card
 * needed.
 *
 * The flash command sequences (erase/write/read/status-poll) are Xilinx's
 * own reference example for this exact driver+flash-family combination
 * (XilinxProcessorIPLib/drivers/qspips/examples/xqspips_flash_polled_example.c),
 * which explicitly documents Spansion S25FL support and uses the same
 * 64KB-sector/256B-page geometry as the S25FL128S; only the top-level
 * control flow (SD-to-flash copy instead of a self-test pattern) is new.
 */
#include <string.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xqspips.h"
#include "ff.h"

#define QSPI_DEVICE_ID  XPAR_XQSPIPS_0_DEVICE_ID
#define SOURCE_FILE     "TARGET.BIN"

#define WRITE_CMD        0x02
#define READ_CMD         0x03
#define READ_STATUS_CMD  0x05
#define WRITE_ENABLE_CMD 0x06
#define SEC_ERASE_CMD    0xD8
#define READ_ID          0x9F

#define COMMAND_OFFSET   0
#define ADDRESS_1_OFFSET 1
#define ADDRESS_2_OFFSET 2
#define ADDRESS_3_OFFSET 3
#define DATA_OFFSET      4
#define OVERHEAD_SIZE    4
#define SEC_ERASE_SIZE   4

#define SECTOR_SIZE 0x10000U   /* 64KB erase sector, S25FL128S */
#define PAGE_SIZE   256U       /* max program size per command */
#define FLASH_SIZE  0x1000000U /* 16MB, S25FL128S */

static XQspiPs QspiInstance;
static u8 WriteBuffer[PAGE_SIZE + DATA_OFFSET];
static u8 ReadBuffer[PAGE_SIZE + DATA_OFFSET];
static u8 PageBuffer[PAGE_SIZE];
static u8 VerifyBuffer[PAGE_SIZE];

/* Bounded: an earlier unbounded version of this loop hung forever with
 * no diagnostic when it got stuck (real hardware run: silently wedged
 * right at a 4MB/sector-64 boundary, cause unconfirmed -- possibly a
 * factory write-protected region silently rejecting the erase, which
 * would leave WIP permanently set). ~10M iterations is generously above
 * the flash's documented worst-case erase time. */
#define FLASH_READY_TIMEOUT 10000000UL

static int FlashWaitReady(XQspiPs *QspiPtr)
{
	u8 ReadStatusCmd[] = { READ_STATUS_CMD, 0 };
	u8 FlashStatus[2];
	unsigned long i;
	for (i = 0; i < FLASH_READY_TIMEOUT; i++) {
		XQspiPs_PolledTransfer(QspiPtr, ReadStatusCmd, FlashStatus, sizeof(ReadStatusCmd));
		FlashStatus[1] |= FlashStatus[0];
		if ((FlashStatus[1] & 0x01) == 0)
			return 0;
	}
	xil_printf("ERROR: flash status register stuck (last read: 0x%x)\n\r", FlashStatus[1]);
	return -1;
}

static void FlashWriteEnable(XQspiPs *QspiPtr)
{
	u8 WriteEnableCmd = WRITE_ENABLE_CMD;
	XQspiPs_PolledTransfer(QspiPtr, &WriteEnableCmd, NULL, sizeof(WriteEnableCmd));
}

static int FlashEraseSector(XQspiPs *QspiPtr, u32 Address)
{
	FlashWriteEnable(QspiPtr);
	WriteBuffer[COMMAND_OFFSET]   = SEC_ERASE_CMD;
	WriteBuffer[ADDRESS_1_OFFSET] = (u8)(Address >> 16);
	WriteBuffer[ADDRESS_2_OFFSET] = (u8)(Address >> 8);
	WriteBuffer[ADDRESS_3_OFFSET] = (u8)(Address & 0xFF);
	XQspiPs_PolledTransfer(QspiPtr, WriteBuffer, NULL, SEC_ERASE_SIZE);
	if (FlashWaitReady(QspiPtr) != 0) {
		xil_printf("ERROR: erase timed out at 0x%06x\n\r", Address);
		return -1;
	}
	return 0;
}

static int FlashWritePage(XQspiPs *QspiPtr, u32 Address, u8 *Data, u32 Count)
{
	FlashWriteEnable(QspiPtr);
	WriteBuffer[COMMAND_OFFSET]   = WRITE_CMD;
	WriteBuffer[ADDRESS_1_OFFSET] = (u8)(Address >> 16);
	WriteBuffer[ADDRESS_2_OFFSET] = (u8)(Address >> 8);
	WriteBuffer[ADDRESS_3_OFFSET] = (u8)(Address & 0xFF);
	memcpy(&WriteBuffer[DATA_OFFSET], Data, Count);
	XQspiPs_PolledTransfer(QspiPtr, WriteBuffer, NULL, Count + OVERHEAD_SIZE);
	if (FlashWaitReady(QspiPtr) != 0) {
		xil_printf("ERROR: page program timed out at 0x%06x\n\r", Address);
		return -1;
	}
	return 0;
}

static void FlashReadData(XQspiPs *QspiPtr, u32 Address, u8 *Data, u32 Count)
{
	WriteBuffer[COMMAND_OFFSET]   = READ_CMD;
	WriteBuffer[ADDRESS_1_OFFSET] = (u8)(Address >> 16);
	WriteBuffer[ADDRESS_2_OFFSET] = (u8)(Address >> 8);
	WriteBuffer[ADDRESS_3_OFFSET] = (u8)(Address & 0xFF);
	XQspiPs_PolledTransfer(QspiPtr, WriteBuffer, ReadBuffer, Count + OVERHEAD_SIZE);
	memcpy(Data, &ReadBuffer[DATA_OFFSET], Count);
}

int main()
{
	FATFS fatfs;
	FIL file;
	FRESULT res;
	XQspiPs_Config *QspiConfig;
	u32 address = 0, total_written = 0;
	int mismatch = 0;

	init_platform();
	xil_printf("\n\rQSPI flash writer: %s -> onboard QSPI flash\n\r", SOURCE_FILE);

	res = f_mount(&fatfs, "0:/", 0);
	if (res != FR_OK) {
		xil_printf("ERROR: SD mount failed (%d)\n\r", res);
		goto done;
	}

	res = f_open(&file, SOURCE_FILE, FA_READ);
	if (res != FR_OK) {
		xil_printf("ERROR: could not open %s on SD card (%d)\n\r", SOURCE_FILE, res);
		goto done;
	}

	QspiConfig = XQspiPs_LookupConfig(QSPI_DEVICE_ID);
	if (QspiConfig == NULL || XQspiPs_CfgInitialize(&QspiInstance, QspiConfig,
			QspiConfig->BaseAddress) != XST_SUCCESS) {
		xil_printf("ERROR: QSPI init failed\n\r");
		goto close_file;
	}
	XQspiPs_SetOptions(&QspiInstance, XQSPIPS_MANUAL_START_OPTION |
			XQSPIPS_FORCE_SSELECT_OPTION | XQSPIPS_HOLD_B_DRIVE_OPTION);
	XQspiPs_SetClkPrescaler(&QspiInstance, XQSPIPS_CLK_PRESCALE_8);
	XQspiPs_SetSlaveSelect(&QspiInstance);

	WriteBuffer[COMMAND_OFFSET] = READ_ID;
	XQspiPs_PolledTransfer(&QspiInstance, WriteBuffer, ReadBuffer, 4);
	xil_printf("Flash ID: 0x%x 0x%x 0x%x\n\r", ReadBuffer[1], ReadBuffer[2], ReadBuffer[3]);

	while (address < FLASH_SIZE) {
		UINT br;

		/* Erase each 64KB sector once, right before its first page. */
		if (address % SECTOR_SIZE == 0) {
			xil_printf("erasing sector at 0x%06x...\n\r", address);
			if (FlashEraseSector(&QspiInstance, address) != 0) {
				mismatch = 1;
				break;
			}
		}

		memset(PageBuffer, 0xFF, PAGE_SIZE);
		res = f_read(&file, PageBuffer, PAGE_SIZE, &br);
		if (res != FR_OK) {
			xil_printf("ERROR: SD read failed (%d)\n\r", res);
			break;
		}
		if (br == 0)
			break; /* EOF, nothing more to write */

		if (FlashWritePage(&QspiInstance, address, PageBuffer, PAGE_SIZE) != 0) {
			mismatch = 1;
			break;
		}
		FlashReadData(&QspiInstance, address, VerifyBuffer, PAGE_SIZE);
		if (memcmp(VerifyBuffer, PageBuffer, PAGE_SIZE) != 0) {
			xil_printf("VERIFY MISMATCH at 0x%06x\n\r", address);
			mismatch = 1;
		}

		total_written += br;
		if ((address / SECTOR_SIZE) != ((address + PAGE_SIZE) / SECTOR_SIZE))
			xil_printf("wrote+verified through 0x%06x (%u bytes so far)\n\r",
					address, total_written);

		address += PAGE_SIZE;
		if (br < PAGE_SIZE)
			break; /* EOF reached mid-page -- done */
	}

	f_close(&file);

	if (mismatch) {
		xil_printf("\n\rDONE WITH ERRORS: verification mismatch -- do NOT boot from QSPI\n\r");
	} else if (total_written == 0) {
		xil_printf("\n\rDONE WITH ERRORS: nothing was written\n\r");
	} else {
		xil_printf("\n\rDONE: %u bytes written and verified.\n\r", total_written);
		xil_printf("Set JP5 to QSPI and power-cycle the board.\n\r");
	}
	goto done;

close_file:
	f_close(&file);
done:
	cleanup_platform();
	return 0;
}
