// 27 MHz -> 126 MHz (5 x 25.2 MHz pixel clock). Generated with:
//   gowin_pll -i 27 -o 126 -d "GW2A-18 C8/I7"   (PFD 9 MHz, VCO 504 MHz)
module pll_126 (
    input  wire clkin,
    output wire clkout,
    output wire locked
);
    rPLL #(
        .FCLKIN("27.0"),
        .IDIV_SEL(2),
        .FBDIV_SEL(13),
        .ODIV_SEL(4)
    ) pll (
        .CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0),
        .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0),
        .CLKIN(clkin), .CLKOUT(clkout), .LOCK(locked)
    );
endmodule
