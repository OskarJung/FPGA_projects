`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.03.2026 23:32:07
// Design Name: 
// Module Name: Delay_Line
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


module Delay_Line #
    (
        parameter N = 4,
        parameter DELAY = 4
    )
    (
        input clk,
        input ce,
        input [N-1:0] idata,
        output [N-1:0] odata
    );
    
    wire [N-1:0] tdata [DELAY:0];
    
    genvar i;
    generate
        if (DELAY == 0)
            begin
                assign odata = idata;
            end else
            begin
                assign tdata[0] = idata;
                for(i=0; i<DELAY; i=i+1)
                    begin : loop_delay
                        Delay_register #( .N(N))
                            register_i
                            (
                                .d(tdata[i]),
                                .q(tdata[i+1]),
                                .ce(ce),
                                .clk(clk)
                            );    
                    end  
                assign odata = tdata[DELAY];
            end
    endgenerate 
endmodule
