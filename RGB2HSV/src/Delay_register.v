`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2026 00:29:33
// Design Name: 
// Module Name: Delay_register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Delay_register #
    (
        parameter N = 4
    )
    (
        input clk,
        input ce,
        input [N-1:0]d,
        output [N-1:0]q
    );
    
    reg [N-1:0] val = 0;
    
    always @(posedge clk)
        begin
            if(ce) val <= d;
            else val <= val;
        end
    assign q=val;
endmodule

