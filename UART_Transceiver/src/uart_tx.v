`timescale 1ns / 1ps

module uart_tx(
    input clk,
    input rst,
    input send,
    input [7:0]data,
    output txd
    );
    
    localparam STATE0 = 2'd0;
    localparam STATE1 = 2'd1;
    localparam STATE2 = 2'd2;
    localparam STATE3 = 2'd3;
    
    reg r_send = 0;
    reg r_txd = 0;
    reg [1:0] state = STATE0;
    reg [7:0] r_data;
    reg [2:0] cnt = 3'b0;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= STATE0;
            r_txd <= 0;
            cnt <= 0;
            r_send <= 0;
        end 
        else begin
            r_send <= send;
            case(state)
                STATE0: begin
                    if (r_send < send) begin
                        state <= STATE1;
                        r_data <= data;
                    end
                end
                STATE1: begin
                    r_txd <= 1;
                    state <= STATE2;
                end
                STATE2: begin
                    r_txd <= r_data[cnt]; 
                    if (cnt == 3'b111) begin
                        cnt <= 3'b000;
                        state <= STATE3;
                    end
                    else cnt <= cnt + 1;
                end
                STATE3: begin
                    r_txd <= 0;
                    state <= STATE0;
                end
            endcase
        end 
    end
    
    assign txd = r_txd; 
    
endmodule
