`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2026 14:37:19
// Design Name: 
// Module Name: modulo_logic
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

module modulo_logic (
    input  wire [7:0] x,
    input  wire [7:0] y,
    output wire out
);
    wire [7:0] tree [3:0]; 

    genvar i, j;
    generate
        for (j = 0; j < 8; j = j + 1) begin : input_and_gates
            assign tree[0][j] = x[j] & y[j];
        end
        for (i = 1; i < 4; i = i + 1) begin : stage
            for (j = 0; j < (8 >> i); j = j + 1) begin : node
                if (i % 2 == 1) begin : or_layer
                    assign tree[i][j] = tree[i-1][2*j] | tree[i-1][2*j+1];
                end else begin : and_layer
                    assign tree[i][j] = tree[i-1][2*j] & tree[i-1][2*j+1];
                end
                
            end
        end
    endgenerate
    assign out = tree[3][0];

endmodule


