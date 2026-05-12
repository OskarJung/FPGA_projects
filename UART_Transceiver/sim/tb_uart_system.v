`timescale 1ns / 1ps

module tb_uart_system();
    reg clk = 1'b0;
    reg rst = 1'b0;
    wire send;
    
    wire [7:0]data_tx; 
    
    wire received;
    wire [7:0]data_rx;
    
    wire line;
    
    load_file load_i(
        .data(data_tx),
        .send(send)    
    );
    
    uart_tx dut1(
        .clk(clk), //in
        .rst(rst), //in
        .data(data_tx), //in
        .send(send), //in
        .txd(line) //out
    );
    
    uart_rx dut2 (
        .clk(clk), //in
        .rst(rst), //in
        .rxd(line), //in
        .received(received), //out
        .data(data_rx) //out
    );
    
    save_ascii save_i(
        .data(data_rx), //in
        .received(received) //in
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
