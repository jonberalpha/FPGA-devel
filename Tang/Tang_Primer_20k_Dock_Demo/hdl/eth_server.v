// Minimal Ethernet server on an RMII PHY (50 MHz): ARP, ICMP echo and a stateless TCP/HTTP server.
//
// Whole frames are received into one 2 KiB buffer, the headers are snapshotted, a reply is composed
// in the same buffer, IP/TCP checksums are computed in a pass over the buffer and the frame is sent
// with the FCS appended. The TCP server keeps no connection state: the sequence number of a reply is
// taken from the acknowledgement number of the request, so a request that is retransmitted
// is simply answered again.
//
//   GET /l5/on, /l5/off, /l4/..., /l3/...  switch the LEDs, every request returns the page.

module eth_server #(
    parameter [47:0] MY_MAC = 48'h02_54_41_4E_47_20,
    parameter [31:0] MY_IP  = {8'd192, 8'd168, 8'd50, 8'd2},
    parameter [31:0] ISN    = 32'h0001_0000
) (
    input  wire       clk,            // RMII reference clock, 50 MHz
    input  wire       rst,

    input  wire [1:0] rxd,
    input  wire       crs_dv,
    output reg  [1:0] txd = 2'b00,
    output reg        tx_en = 1'b0,

    input  wire [2:0] led_state,      // {LED3, LED4, LED5}, from another clock domain
    output reg  [2:0] led_tgl = 3'b0, // toggles on every request (clock domain crossing by toggle)
    output reg  [2:0] led_val = 3'b0,
    output reg        req_tgl = 1'b0, // toggles for every served HTTP request
    output reg        rx_tgl  = 1'b0  // toggles for every received frame
);
    `include "http_page.vh"

    // ---------------------------------------------------------------- buffer
    reg [7:0]  mem [0:2047];
    reg [10:0] a = 11'd0;
    reg        we = 1'b0;
    reg [7:0]  wd = 8'd0;
    reg [7:0]  rd = 8'd0;
    always @(posedge clk) begin
        if (we) mem[a] <= wd;
        rd <= mem[a];
    end

    reg [7:0] page [0:PAGE_LEN-1];
    initial $readmemh("hdl/http_page.hex", page);
    reg [10:0] page_a = 11'd0;
    reg [7:0]  page_q = 8'd0;
    always @(posedge clk) page_q <= page[page_a];

    // ---------------------------------------------------------------- main state
    localparam S_IDLE = 4'd0, S_PARSE = 4'd1, S_DECIDE = 4'd2, S_REQ = 4'd3, S_COMP = 4'd4,
               S_CK = 4'd5, S_TX = 4'd6, S_GAP = 4'd7;
    reg [3:0] st = S_IDLE;

    // ---------------------------------------------------------------- receiver
    reg [1:0]  rs = 2'd0;
    reg [1:0]  dcnt = 2'd0;
    reg [7:0]  rsh = 8'd0;
    reg [11:0] wptr = 12'd0;
    reg        acc = 1'b0;
    reg        rx_we = 1'b0;
    reg [10:0] rx_wa = 11'd0;
    reg [7:0]  rx_wd = 8'd0;
    reg        rx_done = 1'b0;
    reg [11:0] rx_len = 12'd0;

    always @(posedge clk) begin
        rx_we   <= 1'b0;
        rx_done <= 1'b0;
        case (rs)
            2'd0: if (crs_dv) rs <= 2'd1;
            2'd1: if (!crs_dv) rs <= 2'd0;
                  else if (rxd == 2'b11) begin   // SFD
                      rs <= 2'd2; dcnt <= 2'd0; wptr <= 12'd0; acc <= (st == S_IDLE);
                  end
            default: begin
                if (!crs_dv) begin
                    rs <= 2'd0;
                    if (acc) begin rx_done <= 1'b1; rx_len <= wptr; end
                end else begin
                    rsh  <= {rxd, rsh[7:2]};
                    dcnt <= dcnt + 2'd1;
                    if (dcnt == 2'd3) begin
                        if (acc && wptr < 12'd2048) begin
                            rx_we <= 1'b1; rx_wa <= wptr[10:0]; rx_wd <= {rxd, rsh[7:2]};
                        end
                        wptr <= wptr + 12'd1;
                    end
                end
            end
        endcase
    end

    // ---------------------------------------------------------------- snapshot of the received headers
    reg [47:0] src_mac;
    reg [15:0] etype;
    reg [7:0]  b14, b20, b21, proto;
    reg [15:0] totlen;
    reg [31:0] ip_src, ip_dst, arp_spa;
    reg [7:0]  r34, r35, r36, r37, b46, b47;
    reg [31:0] w38, w42;
    reg [7:0]  req [0:9];

    reg [6:0]  p = 7'd0;                 // parse / request read counter
    reg [3:0]  kind = 4'd0;
    localparam K_NONE = 4'd0, K_ARP = 4'd1, K_ICMP = 4'd2, K_SYN = 4'd3, K_DATA = 4'd4, K_FIN = 4'd5;

    wire [15:0] sport = {r34, r35};
    wire [15:0] dport = {r36, r37};
    wire [3:0]  doff  = b46[7:4];
    wire [15:0] pay_len = totlen - 16'd20 - {10'd0, doff, 2'b00};

    wire ip_ok     = (etype == 16'h0800) && (b14 == 8'h45) && (ip_dst == MY_IP);
    wire is_arp    = (etype == 16'h0806) && (b20 == 8'd0) && (b21 == 8'd1) && (w38 == MY_IP);
    wire is_icmp   = ip_ok && (proto == 8'd1) && (r34 == 8'd8);
    wire is_tcp    = ip_ok && (proto == 8'd6) && (dport == 16'd80) && (doff >= 4'd5);
    wire f_syn = b47[1], f_ack = b47[4], f_fin = b47[0], f_rst = b47[2];
    wire [15:0] ack_len = pay_len + {15'd0, f_fin};   // payload bytes plus one for a piggy-backed FIN

    // ---------------------------------------------------------------- compose
    reg [11:0] ci = 12'd0;               // next compose index
    reg [11:0] wi = 12'd0, wi1 = 12'd0;  // index being written
    reg [1:0]  cpipe = 2'd0;
    reg [11:0] comp_end = 12'd0;
    reg [11:0] tx_len = 12'd0;
    reg [2:0]  ledq = 3'b0;

    reg [31:0] seq_out, ack_out;
    reg [7:0]  flags_out;
    reg [15:0] ip_tot;

    wire [16:0] icmp_sum = {1'b0, r36, r37} + 17'h0800;
    wire [15:0] icmp_ck  = icmp_sum[15:0] + {15'd0, icmp_sum[16]};

    function [7:0] hdr_byte(input [11:0] i);
        reg [47:0] dmac;
        begin
            hdr_byte = 8'h00;
            if (i < 12'd6)        hdr_byte = src_mac[8*(5-i) +: 8];
            else if (i < 12'd12)  hdr_byte = MY_MAC[8*(11-i) +: 8];
            else if (i == 12'd12) hdr_byte = (kind == K_ARP) ? 8'h08 : 8'h08;
            else if (i == 12'd13) hdr_byte = (kind == K_ARP) ? 8'h06 : 8'h00;
            else if (kind == K_ARP) begin
                case (i)
                    14: hdr_byte = 8'h00; 15: hdr_byte = 8'h01; 16: hdr_byte = 8'h08; 17: hdr_byte = 8'h00;
                    18: hdr_byte = 8'h06; 19: hdr_byte = 8'h04; 20: hdr_byte = 8'h00; 21: hdr_byte = 8'h02;
                    22,23,24,25,26,27: hdr_byte = MY_MAC[8*(27-i) +: 8];
                    28,29,30,31:       hdr_byte = MY_IP[8*(31-i) +: 8];
                    32,33,34,35,36,37: hdr_byte = src_mac[8*(37-i) +: 8];
                    38,39,40,41:       hdr_byte = arp_spa[8*(41-i) +: 8];
                    default: hdr_byte = 8'h00;
                endcase
            end else begin
                case (i)
                    14: hdr_byte = 8'h45; 15: hdr_byte = 8'h00;
                    16: hdr_byte = ip_tot[15:8]; 17: hdr_byte = ip_tot[7:0];
                    18: hdr_byte = 8'h00; 19: hdr_byte = 8'h00;
                    20: hdr_byte = 8'h40; 21: hdr_byte = 8'h00;
                    22: hdr_byte = 8'h40; 23: hdr_byte = (kind == K_ICMP) ? 8'd1 : 8'd6;
                    24: hdr_byte = 8'h00; 25: hdr_byte = 8'h00;
                    26,27,28,29: hdr_byte = MY_IP[8*(29-i) +: 8];
                    30,31,32,33: hdr_byte = ip_src[8*(33-i) +: 8];
                    default: begin
                        if (kind == K_ICMP) begin
                            case (i)
                                34: hdr_byte = 8'h00;          // echo reply
                                35: hdr_byte = 8'h00;
                                // checksum adjusted by +0x0800 (type 8 -> 0), one's complement
                                36: hdr_byte = icmp_ck[15:8];
                                37: hdr_byte = icmp_ck[7:0];
                                default: hdr_byte = 8'h00;
                            endcase
                        end else begin
                            case (i)
                                34: hdr_byte = 8'd0;  35: hdr_byte = 8'd80;
                                36: hdr_byte = r34;   37: hdr_byte = r35;
                                38,39,40,41: hdr_byte = seq_out[8*(41-i) +: 8];
                                42,43,44,45: hdr_byte = ack_out[8*(45-i) +: 8];
                                46: hdr_byte = 8'h50; 47: hdr_byte = flags_out;
                                48: hdr_byte = 8'h04; 49: hdr_byte = 8'h00;
                                default: hdr_byte = 8'h00;     // checksum, urgent pointer
                            endcase
                        end
                    end
                endcase
            end
        end
    endfunction

    // page byte with LED state words substituted
    function [7:0] page_byte(input [11:0] j, input [7:0] q);
        reg [2:0] k;
        reg on;
        begin
            page_byte = q;
            if (j >= SLOT_L5 && j < SLOT_L5 + 3) begin on = ledq[0]; k = j - SLOT_L5; end
            else if (j >= SLOT_L4 && j < SLOT_L4 + 3) begin on = ledq[1]; k = j - SLOT_L4; end
            else if (j >= SLOT_L3 && j < SLOT_L3 + 3) begin on = ledq[2]; k = j - SLOT_L3; end
            else begin on = 1'b0; k = 3'd7; end
            if (k != 3'd7) begin
                if (on) page_byte = (k == 3'd0) ? "O" : (k == 3'd1) ? "N" : " ";
                else    page_byte = (k == 3'd0) ? "O" : "F";
            end
        end
    endfunction

    // ---------------------------------------------------------------- checksum pass
    reg [31:0] ck_sum;
    reg [11:0] ck_cur, ck_end;
    reg [11:0] ck_wr;
    reg [1:0]  ck_ph;
    reg [7:0]  ck_hi;
    reg        ck_tcp_next;
    reg [2:0]  ck_stage;

    wire [31:0] fold1 = {16'd0, ck_sum[15:0]} + {16'd0, ck_sum[31:16]};
    wire [15:0] fold2 = fold1[15:0] + fold1[31:16];

    // ---------------------------------------------------------------- transmitter
    reg [1:0]  tph = 2'd0;               // 0 preamble, 1 data, 2 fcs
    reg [11:0] tn = 12'd0;
    reg [1:0]  tdc = 2'd0;
    reg [7:0]  tsh = 8'd0;
    reg [7:0]  dbyte = 8'd0;
    reg [31:0] crc = 32'hffff_ffff;
    reg [31:0] crcf = 32'd0;
    reg [7:0]  gap = 8'd0;

    function [31:0] crc_byte(input [31:0] c, input [7:0] d);
        integer k;
        reg [31:0] x;
        begin
            x = c ^ {24'd0, d};
            for (k = 0; k < 8; k = k + 1)
                x = x[0] ? ((x >> 1) ^ 32'hEDB88320) : (x >> 1);
            crc_byte = x;
        end
    endfunction

    reg [7:0] cur;

    // ---------------------------------------------------------------- main FSM
    reg [3:0] led_i;
    always @(posedge clk) begin
        we <= 1'b0;
        if (rst) begin
            st <= S_IDLE;
            tx_en <= 1'b0;
        end else begin
            case (st)
            // ------------------------------------------------------------ wait for a frame
            S_IDLE: begin
                a <= rx_wa; we <= rx_we; wd <= rx_wd;
                if (rx_done && rx_len >= 12'd42 + 12'd4) begin
                    rx_tgl <= ~rx_tgl;
                    p <= 7'd0;
                    st <= S_PARSE;
                end
            end
            // ------------------------------------------------------------ read bytes 0..53 (read latency: 2 cycles)
            S_PARSE: begin
                a <= {4'd0, p};
                if (p >= 7'd2) begin
                    case (p - 7'd2)
                        6,7,8,9,10,11: src_mac <= {src_mac[39:0], rd};
                        12: etype[15:8] <= rd;
                        13: etype[7:0]  <= rd;
                        14: b14 <= rd;
                        16: totlen[15:8] <= rd;
                        17: totlen[7:0]  <= rd;
                        20: b20 <= rd;
                        21: b21 <= rd;
                        23: proto <= rd;
                        26,27,28,29: ip_src <= {ip_src[23:0], rd};
                        30,31,32,33: ip_dst <= {ip_dst[23:0], rd};
                        34: r34 <= rd;
                        35: r35 <= rd;
                        36: r36 <= rd;
                        37: r37 <= rd;
                        38,39,40,41: w38 <= {w38[23:0], rd};
                        42,43,44,45: w42 <= {w42[23:0], rd};
                        46: b46 <= rd;
                        47: b47 <= rd;
                        default: ;
                    endcase
                    // ARP sender protocol address sits at bytes 28..31
                    if (p - 7'd2 >= 28 && p - 7'd2 <= 31) arp_spa <= {arp_spa[23:0], rd};
                end
                p <= p + 7'd1;
                if (p == 7'd55) st <= S_DECIDE;
            end
            // ------------------------------------------------------------ classify
            S_DECIDE: begin
                kind <= K_NONE;
                ledq <= led_state;
                if (is_arp) begin
                    kind <= K_ARP;  comp_end <= 12'd60; tx_len <= 12'd60;
                    st <= S_COMP; ci <= 12'd0; cpipe <= 2'd0;
                end else if (is_icmp) begin
                    kind <= K_ICMP; comp_end <= 12'd38;
                    ip_tot <= totlen;
                    tx_len <= (totlen[11:0] < 12'd46) ? 12'd60 : (12'd14 + totlen[11:0]);
                    st <= S_COMP; ci <= 12'd0; cpipe <= 2'd0;
                end else if (is_tcp && !f_rst) begin
                    if (f_syn && !f_ack) begin
                        kind <= K_SYN; seq_out <= ISN; ack_out <= w38 + 32'd1; flags_out <= 8'h12;
                        ip_tot <= 16'd40; comp_end <= 12'd60; tx_len <= 12'd60;
                        st <= S_COMP; ci <= 12'd0; cpipe <= 2'd0;
                    end else if (pay_len != 16'd0) begin
                        kind <= K_DATA; seq_out <= w42; ack_out <= w38 + {16'd0, ack_len};
                        flags_out <= 8'h19; ip_tot <= 16'd40 + PAGE_LEN;
                        comp_end <= 12'd54 + PAGE_LEN; tx_len <= 12'd54 + PAGE_LEN;
                        p <= 7'd0; st <= S_REQ;
                    end else if (f_fin) begin
                        kind <= K_FIN; seq_out <= w42; ack_out <= w38 + 32'd1; flags_out <= 8'h10;
                        ip_tot <= 16'd40; comp_end <= 12'd60; tx_len <= 12'd60;
                        st <= S_COMP; ci <= 12'd0; cpipe <= 2'd0;
                    end else st <= S_IDLE;
                end else st <= S_IDLE;
            end
            // ------------------------------------------------------------ read the first request bytes
            S_REQ: begin
                a <= 11'd34 + {5'd0, doff, 2'b00} + {4'd0, p};
                if (p >= 7'd2 && p <= 7'd11) req[p - 7'd2] <= rd;
                p <= p + 7'd1;
                if (p == 7'd12) begin
                    // "GET /lN/on" or "GET /lN/off"
                    if (req[0] == "G" && req[1] == "E" && req[2] == "T" && req[3] == " " && req[4] == "/" &&
                        req[5] == "l" && req[7] == "/" && req[8] == "o" &&
                        (req[6] == "5" || req[6] == "4" || req[6] == "3") &&
                        (req[9] == "n" || req[9] == "f")) begin
                        led_i = (req[6] == "5") ? 4'd0 : (req[6] == "4") ? 4'd1 : 4'd2;
                        led_tgl[led_i] <= ~led_tgl[led_i];
                        led_val[led_i] <= (req[9] == "n");
                        ledq[led_i]    <= (req[9] == "n");
                    end
                    req_tgl <= ~req_tgl;
                    st <= S_COMP; ci <= 12'd0; cpipe <= 2'd0;
                end
            end
            // ------------------------------------------------------------ build the reply in the buffer
            S_COMP: begin
                // two-stage pipeline: the page ROM address is issued for ci, the byte is written for wi = ci - 2
                page_a <= (ci >= 12'd54) ? (ci - 12'd54) : 11'd0;
                wi1 <= ci;
                wi  <= wi1;
                ci  <= ci + 12'd1;
                if (cpipe != 2'd2) cpipe <= cpipe + 2'd1;
                else begin
                    a  <= wi[10:0];
                    we <= 1'b1;
                    if (wi < ((kind == K_ARP) ? 12'd42 : (kind == K_ICMP) ? 12'd38 : 12'd54))
                        wd <= hdr_byte(wi);
                    else if (kind == K_DATA && wi >= 12'd54)
                        wd <= page_byte(wi - 12'd54, page_q);
                    else
                        wd <= 8'h00;
                    if (wi == comp_end - 12'd1) begin
                        if (kind == K_ARP) begin
                            st <= S_TX; tph <= 2'd0; tn <= 12'd0; tdc <= 2'd0; crc <= 32'hffff_ffff;
                        end else begin
                            ck_sum <= 32'd0; ck_cur <= 12'd14; ck_end <= 12'd34; ck_wr <= 12'd24;
                            ck_ph <= 2'd0; ck_stage <= 3'd0;
                            ck_tcp_next <= (kind != K_ICMP);
                            st <= S_CK;
                        end
                    end
                end
            end
            // ------------------------------------------------------------ checksum passes
            S_CK: begin
                case (ck_ph)
                    2'd0: begin                       // issue read
                        if (ck_cur == ck_end) ck_ph <= 2'd3;
                        else begin a <= ck_cur[10:0]; ck_ph <= 2'd1; end
                    end
                    2'd1: ck_ph <= 2'd2;              // memory latency
                    2'd2: begin                       // accumulate
                        if (!ck_cur[0]) ck_hi <= rd;
                        else ck_sum <= ck_sum + {16'd0, ck_hi, rd};
                        // odd tcp length: the last byte is padded with zero
                        if (ck_cur + 12'd1 == ck_end && !ck_cur[0]) ck_sum <= ck_sum + {16'd0, rd, 8'h00};
                        ck_cur <= ck_cur + 12'd1;
                        ck_ph  <= 2'd0;
                    end
                    2'd3: begin                       // write result (two bytes)
                        if (ck_stage == 3'd0) begin
                            a <= ck_wr[10:0]; we <= 1'b1; wd <= ~fold2[15:8]; ck_stage <= 3'd1;
                        end else begin
                            a <= ck_wr[10:0] + 11'd1; we <= 1'b1; wd <= ~fold2[7:0];
                            ck_stage <= 3'd0;
                            if (ck_tcp_next) begin
                                // TCP: pseudo header + segment
                                ck_tcp_next <= 1'b0;
                                ck_sum <= {16'd0, MY_IP[31:16]} + {16'd0, MY_IP[15:0]} +
                                          {16'd0, ip_src[31:16]} + {16'd0, ip_src[15:0]} + 32'd6 +
                                          ({16'd0, ip_tot} - 32'd20);
                                ck_cur <= 12'd34;
                                ck_end <= 12'd14 + {ip_tot[11:0]};
                                ck_wr  <= 12'd50;
                                ck_ph  <= 2'd0;
                            end else begin
                                st <= S_TX; tph <= 2'd0; tn <= 12'd0; tdc <= 2'd0; crc <= 32'hffff_ffff;
                            end
                        end
                    end
                endcase
            end
            // ------------------------------------------------------------ send the frame
            S_TX: begin
                tx_en <= 1'b1;
                if (tdc == 2'd0) begin
                    case (tph)
                        2'd0: cur = (tn == 12'd7) ? 8'hD5 : 8'h55;
                        2'd1: cur = dbyte;
                        default: cur = crcf[8*tn[1:0] +: 8];
                    endcase
                    txd <= cur[1:0];
                    tsh <= {2'b00, cur[7:2]};
                    if (tph == 2'd1) crc <= crc_byte(crc, cur);
                end else begin
                    txd <= tsh[1:0];
                    tsh <= {2'b00, tsh[7:2]};
                end
                // fetch the next data byte
                if (tdc == 2'd1) a <= (tph == 2'd0) ? 11'd0 : (tn[10:0] + 11'd1);
                if (tdc == 2'd3) begin
                    dbyte <= rd;
                    tdc <= 2'd0;
                    case (tph)
                        2'd0: if (tn == 12'd7) begin tph <= 2'd1; tn <= 12'd0; end else tn <= tn + 12'd1;
                        2'd1: if (tn == tx_len - 12'd1) begin tph <= 2'd2; tn <= 12'd0; crcf <= ~crc; end
                              else tn <= tn + 12'd1;
                        default: if (tn == 12'd3) begin st <= S_GAP; gap <= 8'd0; end
                                 else tn <= tn + 12'd1;
                    endcase
                end else tdc <= tdc + 2'd1;
            end
            // ------------------------------------------------------------ inter-frame gap
            S_GAP: begin
                tx_en <= 1'b0;
                gap <= gap + 8'd1;
                if (gap == 8'd60) st <= S_IDLE;
            end
            default: st <= S_IDLE;
            endcase
        end
    end
endmodule
