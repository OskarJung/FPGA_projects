`timescale 1ns / 1ps

module save_ascii#(
    parameter FILE_PATH = "../../../../../data/ascii_data_out.bin")
    (
        input [7:0] data,
        input received
    );
    
    integer file;
    integer i = 0;
    
    initial begin
        file = $fopen(FILE_PATH, "w");
        end
        
    always @(posedge received) begin
        $fwrite(file, "%c", data);
        
        i = i + 1;
        
        if (i == 16) begin
            $fclose(file);
            $finish;
       end 
    end    
endmodule
