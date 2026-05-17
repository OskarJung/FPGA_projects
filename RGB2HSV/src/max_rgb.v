`timescale 1ns / 1ps

module max_rgb #(parameter N = 8)(
    input wire clk,
    input wire ce,
    input wire [N-1:0] R,
    input wire [N-1:0] G,
    input wire [N-1:0] B,
    output reg [N-1:0] MAX,
    output reg [1:0] MAX_idx
    );
    
    always @(posedge clk) begin
    if (ce) begin
        if (R >= G && R >= B) begin
            MAX <= R;
            MAX_idx <= 2'd0;
        end
        else if (G >= R && G >= B) begin
            MAX <= G;
            MAX_idx <= 2'd1;
        end
        else begin
            MAX <= B;
            MAX_idx <= 2'd2;
        end 
    end
    end
    
endmodule