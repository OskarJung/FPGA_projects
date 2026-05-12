`timescale 1ns / 1ps

module tb_uart_tx();
    
    reg clk = 1'b0;
    reg rst = 1'b0;
    wire send;
    wire txd;
    wire [7:0]data; 
    
    load_file load_i(
        .data(data),
        .send(send)    
    );
    
    uart_tx dut(
        .clk(clk),
        .rst(rst),
        .data(data), 
        .send(send), 
        .txd(txd)
    );
    
    save_file save_i(
        .one_bit(txd)
    );
    
    initial begin
        while(1)begin
            #1 clk = 1'b0;
            #1 clk = 1'b1;
        end
    end
    
    initial begin
        rst = 1;
        #2
        rst = 0;
    end
endmodule
