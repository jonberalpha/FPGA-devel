                                      1 ;--------------------------------------------------------
                                      2 ; File Created by SDCC : free open source ANSI-C Compiler
                                      3 ; Version 4.2.0 #13081 (Linux)
                                      4 ;--------------------------------------------------------
                                      5 	.module main
                                      6 	.optsdcc -mmcs51 --model-small
                                      7 	
                                      8 ;--------------------------------------------------------
                                      9 ; Public variables in this module
                                     10 ;--------------------------------------------------------
                                     11 	.globl _main
                                     12 	.globl _TF2
                                     13 	.globl _EXF2
                                     14 	.globl _RCLK
                                     15 	.globl _TCLK
                                     16 	.globl _EXEN2
                                     17 	.globl _TR2
                                     18 	.globl _C_T2
                                     19 	.globl _CP_RL2
                                     20 	.globl _T2CON_7
                                     21 	.globl _T2CON_6
                                     22 	.globl _T2CON_5
                                     23 	.globl _T2CON_4
                                     24 	.globl _T2CON_3
                                     25 	.globl _T2CON_2
                                     26 	.globl _T2CON_1
                                     27 	.globl _T2CON_0
                                     28 	.globl _PT2
                                     29 	.globl _ET2
                                     30 	.globl _CY
                                     31 	.globl _AC
                                     32 	.globl _F0
                                     33 	.globl _RS1
                                     34 	.globl _RS0
                                     35 	.globl _OV
                                     36 	.globl _F1
                                     37 	.globl _P
                                     38 	.globl _PS
                                     39 	.globl _PT1
                                     40 	.globl _PX1
                                     41 	.globl _PT0
                                     42 	.globl _PX0
                                     43 	.globl _RD
                                     44 	.globl _WR
                                     45 	.globl _T1
                                     46 	.globl _T0
                                     47 	.globl _INT1
                                     48 	.globl _INT0
                                     49 	.globl _TXD
                                     50 	.globl _RXD
                                     51 	.globl _P3_7
                                     52 	.globl _P3_6
                                     53 	.globl _P3_5
                                     54 	.globl _P3_4
                                     55 	.globl _P3_3
                                     56 	.globl _P3_2
                                     57 	.globl _P3_1
                                     58 	.globl _P3_0
                                     59 	.globl _EA
                                     60 	.globl _ES
                                     61 	.globl _ET1
                                     62 	.globl _EX1
                                     63 	.globl _ET0
                                     64 	.globl _EX0
                                     65 	.globl _P2_7
                                     66 	.globl _P2_6
                                     67 	.globl _P2_5
                                     68 	.globl _P2_4
                                     69 	.globl _P2_3
                                     70 	.globl _P2_2
                                     71 	.globl _P2_1
                                     72 	.globl _P2_0
                                     73 	.globl _SM0
                                     74 	.globl _SM1
                                     75 	.globl _SM2
                                     76 	.globl _REN
                                     77 	.globl _TB8
                                     78 	.globl _RB8
                                     79 	.globl _TI
                                     80 	.globl _RI
                                     81 	.globl _P1_7
                                     82 	.globl _P1_6
                                     83 	.globl _P1_5
                                     84 	.globl _P1_4
                                     85 	.globl _P1_3
                                     86 	.globl _P1_2
                                     87 	.globl _P1_1
                                     88 	.globl _P1_0
                                     89 	.globl _TF1
                                     90 	.globl _TR1
                                     91 	.globl _TF0
                                     92 	.globl _TR0
                                     93 	.globl _IE1
                                     94 	.globl _IT1
                                     95 	.globl _IE0
                                     96 	.globl _IT0
                                     97 	.globl _P0_7
                                     98 	.globl _P0_6
                                     99 	.globl _P0_5
                                    100 	.globl _P0_4
                                    101 	.globl _P0_3
                                    102 	.globl _P0_2
                                    103 	.globl _P0_1
                                    104 	.globl _P0_0
                                    105 	.globl _TH2
                                    106 	.globl _TL2
                                    107 	.globl _RCAP2H
                                    108 	.globl _RCAP2L
                                    109 	.globl _T2CON
                                    110 	.globl _B
                                    111 	.globl _ACC
                                    112 	.globl _PSW
                                    113 	.globl _IP
                                    114 	.globl _P3
                                    115 	.globl _IE
                                    116 	.globl _P2
                                    117 	.globl _SBUF
                                    118 	.globl _SCON
                                    119 	.globl _P1
                                    120 	.globl _TH1
                                    121 	.globl _TH0
                                    122 	.globl _TL1
                                    123 	.globl _TL0
                                    124 	.globl _TMOD
                                    125 	.globl _TCON
                                    126 	.globl _PCON
                                    127 	.globl _DPH
                                    128 	.globl _DPL
                                    129 	.globl _SP
                                    130 	.globl _P0
                                    131 ;--------------------------------------------------------
                                    132 ; special function registers
                                    133 ;--------------------------------------------------------
                                    134 	.area RSEG    (ABS,DATA)
      000000                        135 	.org 0x0000
                           000080   136 _P0	=	0x0080
                           000081   137 _SP	=	0x0081
                           000082   138 _DPL	=	0x0082
                           000083   139 _DPH	=	0x0083
                           000087   140 _PCON	=	0x0087
                           000088   141 _TCON	=	0x0088
                           000089   142 _TMOD	=	0x0089
                           00008A   143 _TL0	=	0x008a
                           00008B   144 _TL1	=	0x008b
                           00008C   145 _TH0	=	0x008c
                           00008D   146 _TH1	=	0x008d
                           000090   147 _P1	=	0x0090
                           000098   148 _SCON	=	0x0098
                           000099   149 _SBUF	=	0x0099
                           0000A0   150 _P2	=	0x00a0
                           0000A8   151 _IE	=	0x00a8
                           0000B0   152 _P3	=	0x00b0
                           0000B8   153 _IP	=	0x00b8
                           0000D0   154 _PSW	=	0x00d0
                           0000E0   155 _ACC	=	0x00e0
                           0000F0   156 _B	=	0x00f0
                           0000C8   157 _T2CON	=	0x00c8
                           0000CA   158 _RCAP2L	=	0x00ca
                           0000CB   159 _RCAP2H	=	0x00cb
                           0000CC   160 _TL2	=	0x00cc
                           0000CD   161 _TH2	=	0x00cd
                                    162 ;--------------------------------------------------------
                                    163 ; special function bits
                                    164 ;--------------------------------------------------------
                                    165 	.area RSEG    (ABS,DATA)
      000000                        166 	.org 0x0000
                           000080   167 _P0_0	=	0x0080
                           000081   168 _P0_1	=	0x0081
                           000082   169 _P0_2	=	0x0082
                           000083   170 _P0_3	=	0x0083
                           000084   171 _P0_4	=	0x0084
                           000085   172 _P0_5	=	0x0085
                           000086   173 _P0_6	=	0x0086
                           000087   174 _P0_7	=	0x0087
                           000088   175 _IT0	=	0x0088
                           000089   176 _IE0	=	0x0089
                           00008A   177 _IT1	=	0x008a
                           00008B   178 _IE1	=	0x008b
                           00008C   179 _TR0	=	0x008c
                           00008D   180 _TF0	=	0x008d
                           00008E   181 _TR1	=	0x008e
                           00008F   182 _TF1	=	0x008f
                           000090   183 _P1_0	=	0x0090
                           000091   184 _P1_1	=	0x0091
                           000092   185 _P1_2	=	0x0092
                           000093   186 _P1_3	=	0x0093
                           000094   187 _P1_4	=	0x0094
                           000095   188 _P1_5	=	0x0095
                           000096   189 _P1_6	=	0x0096
                           000097   190 _P1_7	=	0x0097
                           000098   191 _RI	=	0x0098
                           000099   192 _TI	=	0x0099
                           00009A   193 _RB8	=	0x009a
                           00009B   194 _TB8	=	0x009b
                           00009C   195 _REN	=	0x009c
                           00009D   196 _SM2	=	0x009d
                           00009E   197 _SM1	=	0x009e
                           00009F   198 _SM0	=	0x009f
                           0000A0   199 _P2_0	=	0x00a0
                           0000A1   200 _P2_1	=	0x00a1
                           0000A2   201 _P2_2	=	0x00a2
                           0000A3   202 _P2_3	=	0x00a3
                           0000A4   203 _P2_4	=	0x00a4
                           0000A5   204 _P2_5	=	0x00a5
                           0000A6   205 _P2_6	=	0x00a6
                           0000A7   206 _P2_7	=	0x00a7
                           0000A8   207 _EX0	=	0x00a8
                           0000A9   208 _ET0	=	0x00a9
                           0000AA   209 _EX1	=	0x00aa
                           0000AB   210 _ET1	=	0x00ab
                           0000AC   211 _ES	=	0x00ac
                           0000AF   212 _EA	=	0x00af
                           0000B0   213 _P3_0	=	0x00b0
                           0000B1   214 _P3_1	=	0x00b1
                           0000B2   215 _P3_2	=	0x00b2
                           0000B3   216 _P3_3	=	0x00b3
                           0000B4   217 _P3_4	=	0x00b4
                           0000B5   218 _P3_5	=	0x00b5
                           0000B6   219 _P3_6	=	0x00b6
                           0000B7   220 _P3_7	=	0x00b7
                           0000B0   221 _RXD	=	0x00b0
                           0000B1   222 _TXD	=	0x00b1
                           0000B2   223 _INT0	=	0x00b2
                           0000B3   224 _INT1	=	0x00b3
                           0000B4   225 _T0	=	0x00b4
                           0000B5   226 _T1	=	0x00b5
                           0000B6   227 _WR	=	0x00b6
                           0000B7   228 _RD	=	0x00b7
                           0000B8   229 _PX0	=	0x00b8
                           0000B9   230 _PT0	=	0x00b9
                           0000BA   231 _PX1	=	0x00ba
                           0000BB   232 _PT1	=	0x00bb
                           0000BC   233 _PS	=	0x00bc
                           0000D0   234 _P	=	0x00d0
                           0000D1   235 _F1	=	0x00d1
                           0000D2   236 _OV	=	0x00d2
                           0000D3   237 _RS0	=	0x00d3
                           0000D4   238 _RS1	=	0x00d4
                           0000D5   239 _F0	=	0x00d5
                           0000D6   240 _AC	=	0x00d6
                           0000D7   241 _CY	=	0x00d7
                           0000AD   242 _ET2	=	0x00ad
                           0000BD   243 _PT2	=	0x00bd
                           0000C8   244 _T2CON_0	=	0x00c8
                           0000C9   245 _T2CON_1	=	0x00c9
                           0000CA   246 _T2CON_2	=	0x00ca
                           0000CB   247 _T2CON_3	=	0x00cb
                           0000CC   248 _T2CON_4	=	0x00cc
                           0000CD   249 _T2CON_5	=	0x00cd
                           0000CE   250 _T2CON_6	=	0x00ce
                           0000CF   251 _T2CON_7	=	0x00cf
                           0000C8   252 _CP_RL2	=	0x00c8
                           0000C9   253 _C_T2	=	0x00c9
                           0000CA   254 _TR2	=	0x00ca
                           0000CB   255 _EXEN2	=	0x00cb
                           0000CC   256 _TCLK	=	0x00cc
                           0000CD   257 _RCLK	=	0x00cd
                           0000CE   258 _EXF2	=	0x00ce
                           0000CF   259 _TF2	=	0x00cf
                                    260 ;--------------------------------------------------------
                                    261 ; overlayable register banks
                                    262 ;--------------------------------------------------------
                                    263 	.area REG_BANK_0	(REL,OVR,DATA)
      000000                        264 	.ds 8
                                    265 ;--------------------------------------------------------
                                    266 ; internal ram data
                                    267 ;--------------------------------------------------------
                                    268 	.area DSEG    (DATA)
                                    269 ;--------------------------------------------------------
                                    270 ; overlayable items in internal ram
                                    271 ;--------------------------------------------------------
                                    272 	.area	OSEG    (OVR,DATA)
      000008                        273 _main_i1_65536_15:
      000008                        274 	.ds 2
      00000A                        275 _main_i2_65536_15:
      00000A                        276 	.ds 2
                                    277 ;--------------------------------------------------------
                                    278 ; Stack segment in internal ram
                                    279 ;--------------------------------------------------------
                                    280 	.area	SSEG
      00000C                        281 __start__stack:
      00000C                        282 	.ds	1
                                    283 
                                    284 ;--------------------------------------------------------
                                    285 ; indirectly addressable internal ram data
                                    286 ;--------------------------------------------------------
                                    287 	.area ISEG    (DATA)
                                    288 ;--------------------------------------------------------
                                    289 ; absolute internal ram data
                                    290 ;--------------------------------------------------------
                                    291 	.area IABS    (ABS,DATA)
                                    292 	.area IABS    (ABS,DATA)
                                    293 ;--------------------------------------------------------
                                    294 ; bit data
                                    295 ;--------------------------------------------------------
                                    296 	.area BSEG    (BIT)
                                    297 ;--------------------------------------------------------
                                    298 ; paged external ram data
                                    299 ;--------------------------------------------------------
                                    300 	.area PSEG    (PAG,XDATA)
                                    301 ;--------------------------------------------------------
                                    302 ; external ram data
                                    303 ;--------------------------------------------------------
                                    304 	.area XSEG    (XDATA)
                                    305 ;--------------------------------------------------------
                                    306 ; absolute external ram data
                                    307 ;--------------------------------------------------------
                                    308 	.area XABS    (ABS,XDATA)
                                    309 ;--------------------------------------------------------
                                    310 ; external initialized ram data
                                    311 ;--------------------------------------------------------
                                    312 	.area XISEG   (XDATA)
                                    313 	.area HOME    (CODE)
                                    314 	.area GSINIT0 (CODE)
                                    315 	.area GSINIT1 (CODE)
                                    316 	.area GSINIT2 (CODE)
                                    317 	.area GSINIT3 (CODE)
                                    318 	.area GSINIT4 (CODE)
                                    319 	.area GSINIT5 (CODE)
                                    320 	.area GSINIT  (CODE)
                                    321 	.area GSFINAL (CODE)
                                    322 	.area CSEG    (CODE)
                                    323 ;--------------------------------------------------------
                                    324 ; interrupt vector
                                    325 ;--------------------------------------------------------
                                    326 	.area HOME    (CODE)
      000000                        327 __interrupt_vect:
      000000 02 00 06         [24]  328 	ljmp	__sdcc_gsinit_startup
                                    329 ;--------------------------------------------------------
                                    330 ; global & static initialisations
                                    331 ;--------------------------------------------------------
                                    332 	.area HOME    (CODE)
                                    333 	.area GSINIT  (CODE)
                                    334 	.area GSFINAL (CODE)
                                    335 	.area GSINIT  (CODE)
                                    336 	.globl __sdcc_gsinit_startup
                                    337 	.globl __sdcc_program_startup
                                    338 	.globl __start__stack
                                    339 	.globl __mcs51_genXINIT
                                    340 	.globl __mcs51_genXRAMCLEAR
                                    341 	.globl __mcs51_genRAMCLEAR
                                    342 	.area GSFINAL (CODE)
      00005F 02 00 03         [24]  343 	ljmp	__sdcc_program_startup
                                    344 ;--------------------------------------------------------
                                    345 ; Home
                                    346 ;--------------------------------------------------------
                                    347 	.area HOME    (CODE)
                                    348 	.area HOME    (CODE)
      000003                        349 __sdcc_program_startup:
      000003 02 00 62         [24]  350 	ljmp	_main
                                    351 ;	return from main will return to caller
                                    352 ;--------------------------------------------------------
                                    353 ; code
                                    354 ;--------------------------------------------------------
                                    355 	.area CSEG    (CODE)
                                    356 ;------------------------------------------------------------
                                    357 ;Allocation info for local variables in function 'main'
                                    358 ;------------------------------------------------------------
                                    359 ;i1                        Allocated with name '_main_i1_65536_15'
                                    360 ;i2                        Allocated with name '_main_i2_65536_15'
                                    361 ;------------------------------------------------------------
                                    362 ;	./src/main.c:8: void main(void)
                                    363 ;	-----------------------------------------
                                    364 ;	 function main
                                    365 ;	-----------------------------------------
      000062                        366 _main:
                           000007   367 	ar7 = 0x07
                           000006   368 	ar6 = 0x06
                           000005   369 	ar5 = 0x05
                           000004   370 	ar4 = 0x04
                           000003   371 	ar3 = 0x03
                           000002   372 	ar2 = 0x02
                           000001   373 	ar1 = 0x01
                           000000   374 	ar0 = 0x00
                                    375 ;	./src/main.c:13: for (i1=0; i1<10; i1++)
      000062 E4               [12]  376 	clr	a
      000063 F5 08            [12]  377 	mov	_main_i1_65536_15,a
      000065 F5 09            [12]  378 	mov	(_main_i1_65536_15 + 1),a
      000067                        379 00110$:
      000067 C3               [12]  380 	clr	c
      000068 E5 08            [12]  381 	mov	a,_main_i1_65536_15
      00006A 94 0A            [12]  382 	subb	a,#0x0a
      00006C E5 09            [12]  383 	mov	a,(_main_i1_65536_15 + 1)
      00006E 94 00            [12]  384 	subb	a,#0x00
      000070 50 15            [24]  385 	jnc	00107$
                                    386 ;	./src/main.c:15: P2 = 0xFF; // set all eight P2 port pins to logic 1  
      000072 75 A0 FF         [24]  387 	mov	_P2,#0xff
                                    388 ;	./src/main.c:16: P2 = 0x00; // set all eight P2 port pins to logic 0
      000075 75 A0 00         [24]  389 	mov	_P2,#0x00
                                    390 ;	./src/main.c:13: for (i1=0; i1<10; i1++)
      000078 AE 08            [24]  391 	mov	r6,_main_i1_65536_15
      00007A AF 09            [24]  392 	mov	r7,(_main_i1_65536_15 + 1)
      00007C 74 01            [12]  393 	mov	a,#0x01
      00007E 2E               [12]  394 	add	a,r6
      00007F F5 08            [12]  395 	mov	_main_i1_65536_15,a
      000081 E4               [12]  396 	clr	a
      000082 3F               [12]  397 	addc	a,r7
      000083 F5 09            [12]  398 	mov	(_main_i1_65536_15 + 1),a
                                    399 ;	./src/main.c:20: while(1)
      000085 80 E0            [24]  400 	sjmp	00110$
      000087                        401 00107$:
                                    402 ;	./src/main.c:22: P2 = 0xFF; // set all eight P2 port pins to logic 1
      000087 75 A0 FF         [24]  403 	mov	_P2,#0xff
                                    404 ;	./src/main.c:25: for(i1=0; i1<500; i1++)
      00008A E4               [12]  405 	clr	a
      00008B F5 08            [12]  406 	mov	_main_i1_65536_15,a
      00008D F5 09            [12]  407 	mov	(_main_i1_65536_15 + 1),a
      00008F                        408 00116$:
      00008F C3               [12]  409 	clr	c
      000090 E5 08            [12]  410 	mov	a,_main_i1_65536_15
      000092 94 F4            [12]  411 	subb	a,#0xf4
      000094 E5 09            [12]  412 	mov	a,(_main_i1_65536_15 + 1)
      000096 94 01            [12]  413 	subb	a,#0x01
      000098 50 2E            [24]  414 	jnc	00103$
                                    415 ;	./src/main.c:26: for(i2=0; i2<1000; i2++);
      00009A E4               [12]  416 	clr	a
      00009B F5 0A            [12]  417 	mov	_main_i2_65536_15,a
      00009D F5 0B            [12]  418 	mov	(_main_i2_65536_15 + 1),a
      00009F                        419 00113$:
      00009F C3               [12]  420 	clr	c
      0000A0 E5 0A            [12]  421 	mov	a,_main_i2_65536_15
      0000A2 94 E8            [12]  422 	subb	a,#0xe8
      0000A4 E5 0B            [12]  423 	mov	a,(_main_i2_65536_15 + 1)
      0000A6 94 03            [12]  424 	subb	a,#0x03
      0000A8 50 0F            [24]  425 	jnc	00117$
      0000AA AE 0A            [24]  426 	mov	r6,_main_i2_65536_15
      0000AC AF 0B            [24]  427 	mov	r7,(_main_i2_65536_15 + 1)
      0000AE 74 01            [12]  428 	mov	a,#0x01
      0000B0 2E               [12]  429 	add	a,r6
      0000B1 F5 0A            [12]  430 	mov	_main_i2_65536_15,a
      0000B3 E4               [12]  431 	clr	a
      0000B4 3F               [12]  432 	addc	a,r7
      0000B5 F5 0B            [12]  433 	mov	(_main_i2_65536_15 + 1),a
      0000B7 80 E6            [24]  434 	sjmp	00113$
      0000B9                        435 00117$:
                                    436 ;	./src/main.c:25: for(i1=0; i1<500; i1++)
      0000B9 AE 08            [24]  437 	mov	r6,_main_i1_65536_15
      0000BB AF 09            [24]  438 	mov	r7,(_main_i1_65536_15 + 1)
      0000BD 74 01            [12]  439 	mov	a,#0x01
      0000BF 2E               [12]  440 	add	a,r6
      0000C0 F5 08            [12]  441 	mov	_main_i1_65536_15,a
      0000C2 E4               [12]  442 	clr	a
      0000C3 3F               [12]  443 	addc	a,r7
      0000C4 F5 09            [12]  444 	mov	(_main_i1_65536_15 + 1),a
      0000C6 80 C7            [24]  445 	sjmp	00116$
      0000C8                        446 00103$:
                                    447 ;	./src/main.c:28: P2 = 0x00; // set all eight P2 port pins to logic 0
                                    448 ;	./src/main.c:31: for(i1=0; i1<500; i1++)
      0000C8 E4               [12]  449 	clr	a
      0000C9 F5 A0            [12]  450 	mov	_P2,a
      0000CB F5 08            [12]  451 	mov	_main_i1_65536_15,a
      0000CD F5 09            [12]  452 	mov	(_main_i1_65536_15 + 1),a
      0000CF                        453 00122$:
      0000CF C3               [12]  454 	clr	c
      0000D0 E5 08            [12]  455 	mov	a,_main_i1_65536_15
      0000D2 94 F4            [12]  456 	subb	a,#0xf4
      0000D4 E5 09            [12]  457 	mov	a,(_main_i1_65536_15 + 1)
      0000D6 94 01            [12]  458 	subb	a,#0x01
      0000D8 50 AD            [24]  459 	jnc	00107$
                                    460 ;	./src/main.c:32: for(i2=0; i2<1000; i2++);
      0000DA E4               [12]  461 	clr	a
      0000DB F5 0A            [12]  462 	mov	_main_i2_65536_15,a
      0000DD F5 0B            [12]  463 	mov	(_main_i2_65536_15 + 1),a
      0000DF                        464 00119$:
      0000DF C3               [12]  465 	clr	c
      0000E0 E5 0A            [12]  466 	mov	a,_main_i2_65536_15
      0000E2 94 E8            [12]  467 	subb	a,#0xe8
      0000E4 E5 0B            [12]  468 	mov	a,(_main_i2_65536_15 + 1)
      0000E6 94 03            [12]  469 	subb	a,#0x03
      0000E8 50 0F            [24]  470 	jnc	00123$
      0000EA AE 0A            [24]  471 	mov	r6,_main_i2_65536_15
      0000EC AF 0B            [24]  472 	mov	r7,(_main_i2_65536_15 + 1)
      0000EE 74 01            [12]  473 	mov	a,#0x01
      0000F0 2E               [12]  474 	add	a,r6
      0000F1 F5 0A            [12]  475 	mov	_main_i2_65536_15,a
      0000F3 E4               [12]  476 	clr	a
      0000F4 3F               [12]  477 	addc	a,r7
      0000F5 F5 0B            [12]  478 	mov	(_main_i2_65536_15 + 1),a
      0000F7 80 E6            [24]  479 	sjmp	00119$
      0000F9                        480 00123$:
                                    481 ;	./src/main.c:31: for(i1=0; i1<500; i1++)
      0000F9 AE 08            [24]  482 	mov	r6,_main_i1_65536_15
      0000FB AF 09            [24]  483 	mov	r7,(_main_i1_65536_15 + 1)
      0000FD 74 01            [12]  484 	mov	a,#0x01
      0000FF 2E               [12]  485 	add	a,r6
      000100 F5 08            [12]  486 	mov	_main_i1_65536_15,a
      000102 E4               [12]  487 	clr	a
      000103 3F               [12]  488 	addc	a,r7
      000104 F5 09            [12]  489 	mov	(_main_i1_65536_15 + 1),a
                                    490 ;	./src/main.c:34: }
      000106 80 C7            [24]  491 	sjmp	00122$
                                    492 	.area CSEG    (CODE)
                                    493 	.area CONST   (CODE)
                                    494 	.area XINIT   (CODE)
                                    495 	.area CABS    (ABS,CODE)
