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

        // Wektor 1: Wszystkie 0. Oczekiwany wynik: 0
        x_tb = 8'h00; y_tb = 8'h00; 
        #10; 

        // Wektor 2: Wszystkie 1. Oczekiwany wynik: 1
        x_tb = 8'hFF; y_tb = 8'hFF; 
        #10;

        // Wektor 3:  'x' to 1, ale 'y' to 0. 
        // Oczekiwany wynik: 0
        x_tb = 8'hFF; y_tb = 8'h00; 
        #10;

        // Wektor 4: Aktywacja tylko x[0] i y[0]
        // Oczekiwany wynik: 0.
        x_tb = 8'b00000001; y_tb = 8'b00000001; 
        #10;

        // Wektor 5: Aktywacja x[0] i y[0], x[1] i y[2].
        // Oczekiwany wynik: 0.
        x_tb = 8'b00000011; y_tb = 8'b00000011; 
        #10;

        // Wektor 6: Aktywacja x[0] i y[0], x[1] i y[2], x[3] i y[3].
        // Oczekiwany wynik: 1.
        x_tb = 8'b00000111; y_tb = 8'b00000111; 
        #10;

        // Wektor 7: Aktywacja prawej polowy drzewa.
        // Oczekiwany wynik: 1.
        x_tb = 8'b00001111; y_tb = 8'b00001111; 
        #10;

        // Wektor 8: Aktywacja co drugiego bitu (bity 1, 3, 5, 7).
        // Oczekiwany wynik: 1.
        x_tb = 8'b01010101; y_tb = 8'b01010101; 
        #10;

        $finish;
    end

endmodule