`timescale 1ns / 1ps

module tb_rgb2hsv();
    // inputs
    reg clk = 1'b0;
    reg [23:0] pixel_in;
    reg de_in;
    reg hsync_in;
    reg vsync_in;

    // outputs
    wire [23:0] pixel_out;
    wire de_out;
    wire hsync_out;
    wire vsync_out;   
    
    rgb2hsv dut (
        .clk(clk),
        .pixel_in(pixel_in),
        .de_in(de_in),
        .hsync_in(hsync_in),
        .vsync_in(vsync_in),
        .pixel_out(pixel_out),
        .de_out(de_out),
        .hsync_out(hsync_out),
        .vsync_out(vsync_out)
    );

    wire [7:0] sim_H  = pixel_out[23:16];
    wire [7:0] sim_S = pixel_out[15:8];
    wire [7:0] sim_V = pixel_out[7:0]; 
    
    // Clock generation
    always #1 clk = ~clk;

    initial begin
        pixel_in = 24'd0;
        de_in    = 0;
        hsync_in = 0;
        vsync_in = 0;
        
        $display("\n================ START Simulation ================\n");
        
        #20; 
        
        // Test 1: black (R=255, G=100, B=190)
        //expected 0, 128, 128
        @(negedge clk);
        pixel_in = {8'd255, 8'd100, 8'd190}; 
        de_in    = 1;
        hsync_in = 1;

        @(negedge clk);
        de_in = 0;

        #100
        // Test 2: white (R=120, G=120, B=120)
        @(negedge clk);
        pixel_in = {8'd120, 8'd120, 8'd120}; 
        de_in    = 1;

        @(negedge clk);
        de_in = 0;

        #100
        // Test 3: red (R=50, G=200, B=100)
        @(negedge clk);
        pixel_in = {8'd50, 8'd200, 8'd100}; 
        de_in    = 1;

        @(negedge clk);
        de_in = 0;

        #100
        // Test 4: 
        @(negedge clk);
        pixel_in = {8'd10, 8'd50, 8'd250}; 
        de_in    = 1;

        @(negedge clk);
        de_in = 0;

        #100
        // Test 5: matlab (R=255, G=100, B=123)
        @(negedge clk);
        pixel_in = {8'd255, 8'd0, 8'd0}; 
        de_in    = 1;

        @(negedge clk);
        de_in = 0;

        #100
        // End of valid data stream
        @(negedge clk);
        pixel_in = 24'd0;

        // Wait for pipeline flush


        #150; 
        $display("\n================ END SIMULATION =====================\n");
        $finish;
    end

// Monitor block - weryfikacja niezależnie dla każdego etapu potoku
    
    // Etap 1: Po dzieleniu (Latencja 18)
    always @(posedge clk) begin
        if (dut.de_after_div) begin
            $display("Time: %0t | STAGE 1 | R_sfix = %d, G_sfix = %d, B_sfix = %d", 
                     $time, dut.r_01, dut.g_01, dut.b_01);
        end

        if (dut.de_after_min_max) begin
            $display("Time: %0t | STAGE 2 | MAX = %d, MIN = %d, max_idx = %d, min_idx = %d", 
                     $time, dut.MAX, dut.MIN, dut.MAX_idx, dut.MIN_idx);
        end

        if (dut.de_after_C) begin
            // Zmienna C_01 jest zdefiniowana jako signed, więc %d poprawnie wydrukuje znak ujemny
            $display("Time: %0t | STAGE 3 | C = %d (hex: %h)", 
                     $time, dut.C_01, dut.C_01);
            $display("-----------------------------------------------------");
        end
    end

endmodule