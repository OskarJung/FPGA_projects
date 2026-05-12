`timescale 1ns / 1ps

module load_file #(
    parameter FILE_PATH = "../../../../../data/in_data.bin")(
    output [7:0] data,
    output send
    );
    
    integer file;
    reg [7:0] r_data;
    reg [7:0] i;
    reg r_send = 0;
    
    initial
    begin
        file=$fopen(FILE_PATH, "rb");
        #2
        for (i=0; i<16; i=i+1) begin
            r_data=$fgetc(file);
            r_send = 1;
            #2;
            r_send = 0;
            #22;
        end
        $fclose(file);
    end
    
    assign data = r_data;
    assign send = r_send;
endmodule
