// Testbench for eth_server: sends one Ethernet frame (hex file given by +rx=<file>, +len=<bytes>)
// over RMII and writes the transmitted reply frame (including FCS) to +tx=<file>.
`timescale 1ns / 1ps

module tb_eth;
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg [1:0] rxd = 2'b00;
    reg crs_dv = 1'b0;
    wire [1:0] txd;
    wire tx_en;
    reg [2:0] led_state = 3'b010;
    wire [2:0] led_tgl, led_val;
    wire req_tgl, rx_tgl;

    eth_server dut (
        .clk(clk), .rst(rst), .rxd(rxd), .crs_dv(crs_dv), .txd(txd), .tx_en(tx_en),
        .led_state(led_state), .led_tgl(led_tgl), .led_val(led_val), .req_tgl(req_tgl), .rx_tgl(rx_tgl)
    );

    always #10 clk = ~clk; // 50 MHz

    reg [7:0] frame [0:2047];
    integer len, i, j, fd;
    reg [255:0] rxfile, txfile;

    task send_byte(input [7:0] b);
        integer k;
        begin
            for (k = 0; k < 4; k = k + 1) begin
                @(posedge clk);
                rxd <= b[2*k +: 2];
            end
        end
    endtask

    // capture the transmitted frame
    reg [7:0] txbuf [0:2047];
    integer txn = 0;
    reg [7:0] txsh;
    integer txd_cnt = 0;
    reg in_frame = 1'b0;
    reg seen_sfd = 1'b0;
    always @(posedge clk) begin
        if (tx_en) begin
            if (!seen_sfd) begin
                if (txd == 2'b11) begin seen_sfd <= 1'b1; txd_cnt <= 0; end
            end else begin
                txsh <= {txd, txsh[7:2]};
                txd_cnt <= txd_cnt + 1;
                if (txd_cnt % 4 == 3) begin
                    txbuf[txn] <= {txd, txsh[7:2]};
                    txn <= txn + 1;
                end
            end
        end
    end

    initial begin
        if (!$value$plusargs("rx=%s", rxfile)) rxfile = "sim/rx.hex";
        if (!$value$plusargs("tx=%s", txfile)) txfile = "sim/tx.hex";
        if (!$value$plusargs("len=%d", len)) len = 60;
        $readmemh(rxfile, frame);
        repeat (10) @(posedge clk);
        rst <= 1'b0;
        repeat (10) @(posedge clk);
        // frame: preamble (7 x 0x55), SFD, data, FCS (dummy)
        @(posedge clk); crs_dv <= 1'b1;
        for (i = 0; i < 7; i = i + 1) send_byte(8'h55);
        send_byte(8'hD5);
        for (i = 0; i < len; i = i + 1) send_byte(frame[i]);
        for (i = 0; i < 4; i = i + 1) send_byte(8'h00);
        @(posedge clk); crs_dv <= 1'b0; rxd <= 2'b00;
        // wait for the reply
        repeat (40000) @(posedge clk);
        fd = $fopen(txfile, "w");
        for (j = 0; j < txn; j = j + 1) $fdisplay(fd, "%02x", txbuf[j]);
        $fclose(fd);
        $display("TXLEN=%0d LEDTGL=%b LEDVAL=%b REQ=%b", txn, led_tgl, led_val, req_tgl);
        $finish;
    end
endmodule
