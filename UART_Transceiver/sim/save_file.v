`timescale 1ns / 1ps

module save_file#(
    parameter FILE_PATH = "../../../../../data/out_data.bin")(
    input one_bit
    );
    
    integer file;
    reg [7:0]i;
    
    initial begin
        file = $fopen(FILE_PATH, "wb");
        #1
        for (i=0; i<16*12; i=i+1) begin
            #2;
            $fwrite(file, "%b", one_bit);     
        end
        $fclose(file);
    end
endmodule
