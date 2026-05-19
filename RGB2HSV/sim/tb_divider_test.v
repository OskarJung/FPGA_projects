`timescale 1ns / 1ps

module tb_divider_test();
    reg clk = 0;
    reg [9:0] divisor;
    reg [9:0] dividend;
    wire [23:0] dout;
    wire valid;

    // Instancja Twojej dzielarki
    div_S_L22 uut (
        .aclk(clk),
        .s_axis_divisor_tvalid(1'b1),
        .s_axis_divisor_tdata({6'b0, divisor}),
        .s_axis_dividend_tvalid(1'b1),
        .s_axis_dividend_tdata({6'b0, dividend}),
        .m_axis_dout_tvalid(valid),
        .m_axis_dout_tdata(dout)
    );

    always #1 clk = ~clk;

    initial begin
        // test 1: C=156, V=256 (it should be 156 in 8-bit fixed)
        dividend = 10'd156;
        divisor  = 10'd256;
        #100;
        $display("result HEX: %h, DEC: %d", {dout[7:0], 1'b0}, {dout[7:0], 1'b0});
        $finish;
    end
endmodule