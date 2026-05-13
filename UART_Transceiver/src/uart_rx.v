`timescale 1ns / 1ps

module uart_rx(
    input clk,
    input rst,
    input rxd,
    output [7:0] data,
    output reg received
    );
    
    localparam STATE0 = 2'd0;
    localparam STATE2 = 2'd2;
    localparam STATE3 = 2'd3;
    
    reg [1:0] state = STATE0;
    reg [7:0] r_data;
    reg [7:0] data_out_reg = 8'd0;
    reg [2:0] cnt = 3'b0;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= STATE0;
            cnt <= 0;
            received <= 0;
            r_data <= 0;
        end 
        else begin
            received <= 0;
            case(state)
                STATE0: begin
                    if (rxd == 1) begin
                        state <= STATE2;
                    end
                end
                
                STATE2: begin
                    r_data[cnt] <= rxd;
                    if (cnt == 3'b111) begin
                        cnt <= 3'b000;
                        state <= STATE3;
                    end
                    else cnt <= cnt + 1;
                end
                STATE3: begin
                    if (rxd == 1'b0) begin
                        received <= 1;
                        data_out_reg <= r_data;
                        state <= STATE0;
                    end
                end
            endcase
        end 
    end
    
    assign data = data_out_reg;
endmodule
