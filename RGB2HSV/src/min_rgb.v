`timescale 1ns / 1ps

module min_rgb #(parameter N = 8)(
    input wire clk,
    input wire ce,
    input wire [N-1:0] R,
    input wire [N-1:0] G,
    input wire [N-1:0] B,
    output reg [N-1:0] MIN,
    output reg [1:0] MIN_idx
    );
    
    always @(posedge clk) begin
        if (ce) begin
            if (R <= G && R <= B) begin
                MIN     <= R;
                MIN_idx <= 2'd0;
            end
            else if (G <= R && G <= B) begin
                MIN     <= G;
                MIN_idx <= 2'd1;
            end
            else begin
                MIN     <= B;
                MIN_idx <= 2'd2;
            end 
        end
    end
    
endmodule