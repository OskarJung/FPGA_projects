`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2026 16:28:11
// Design Name: 
// Module Name: tb_modulo_logic
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


module tb_modulo_logic;

    reg [7:0] x_tb;
    reg [7:0] y_tb;
    wire out_tb;

    modulo_logic dut (
        .x(x_tb),
        .y(y_tb),
        .out(out_tb)
    );

    initial begin

         // vec 1: All zeros. Expected result: 0
        x_tb = 8'h00; y_tb = 8'h00; 
        #10; 

        // vec 2: All ones. Expected result: 1
        x_tb = 8'hFF; y_tb = 8'hFF; 
        #10;

        // vec 3: 'x' is 1, but 'y' is 0. 
        // Expected result: 0
        x_tb = 8'hFF; y_tb = 8'h00; 
        #10;

        // vec 4: Activate only x[0] and y[0]
        // Expected result: 0
        x_tb = 8'b00000001; y_tb = 8'b00000001; 
        #10;

        // vec 5: Activate x[0] and y[0], x[1] and y[2]
        // Expected result: 0
        x_tb = 8'b00000011; y_tb = 8'b00000011; 
        #10;

        // vec 6: Activate x[0] and y[0], x[1] and y[2], x[3] and y[3]
        // Expected result: 1
        x_tb = 8'b00000111; y_tb = 8'b00000111; 
        #10;

        // vec 7: Activate the right half of the tree
        // Expected result: 1
        x_tb = 8'b00001111; y_tb = 8'b00001111; 
        #10;

        // vec 8: Activate every second bit (bits 1, 3, 5, 7)
        // Expected result: 1
        x_tb = 8'b01010101; y_tb = 8'b01010101; 
        #10;

        $finish;
    end

endmodule
