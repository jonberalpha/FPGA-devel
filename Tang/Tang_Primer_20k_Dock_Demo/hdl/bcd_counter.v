// Decimal counter with DIGITS BCD digits, increments on inc.
module bcd_counter #(
    parameter integer DIGITS = 6
) (
    input  wire                clk,
    input  wire                rst,
    input  wire                inc,
    output reg  [4*DIGITS-1:0] bcd = {4*DIGITS{1'b0}}
);
    integer i;
    reg carry;
    reg [4*DIGITS-1:0] nxt;

    always @* begin
        carry = inc;
        nxt   = bcd;
        for (i = 0; i < DIGITS; i = i + 1) begin
            if (carry) begin
                if (bcd[4*i +: 4] == 4'd9) begin
                    nxt[4*i +: 4] = 4'd0;
                    carry = 1'b1;
                end else begin
                    nxt[4*i +: 4] = bcd[4*i +: 4] + 4'd1;
                    carry = 1'b0;
                end
            end
        end
    end

    always @(posedge clk)
        if (rst) bcd <= {4*DIGITS{1'b0}};
        else     bcd <= nxt;
endmodule
