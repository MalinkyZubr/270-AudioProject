`default_nettype none


module Twiddle_Storage (
    input logic clock,
    input logic reset,
    input logic[4:0] address,
    output logic signed[15:0] real_twiddle,
    output logic signed[15:0] imag_twiddle
);

reg signed[15:0] real_twiddle_register [31:0];
reg signed[15:0] imag_twiddle_register [31:0];

assign real_twiddle_register[0] = 16'b0000001111101000;
assign real_twiddle_register[1] = 16'b0000001111010101;
assign real_twiddle_register[2] = 16'b0000001110011100;
assign real_twiddle_register[3] = 16'b0000001101000000;
assign real_twiddle_register[4] = 16'b0000001011000100;
assign real_twiddle_register[5] = 16'b0000001000101100;
assign real_twiddle_register[6] = 16'b0000000101111111;
assign real_twiddle_register[7] = 16'b0000000011000100;
assign real_twiddle_register[8] = 16'b0000000000000001;
assign real_twiddle_register[9] = 16'b1111111100111101;
assign real_twiddle_register[10] = 16'b1111111010000010;
assign real_twiddle_register[11] = 16'b1111110111010101;
assign real_twiddle_register[12] = 16'b1111110100111101;
assign real_twiddle_register[13] = 16'b1111110011000001;
assign real_twiddle_register[14] = 16'b1111110001100101;
assign real_twiddle_register[15] = 16'b1111110000101100;
assign real_twiddle_register[16] = 16'b1111110000011000;
assign real_twiddle_register[17] = 16'b1111110000101100;
assign real_twiddle_register[18] = 16'b1111110001100101;
assign real_twiddle_register[19] = 16'b1111110011000001;
assign real_twiddle_register[20] = 16'b1111110100111101;
assign real_twiddle_register[21] = 16'b1111110111010101;
assign real_twiddle_register[22] = 16'b1111111010000010;
assign real_twiddle_register[23] = 16'b1111111100111101;
assign real_twiddle_register[24] = 16'b0000000000000000;
assign real_twiddle_register[25] = 16'b0000000011000100;
assign real_twiddle_register[26] = 16'b0000000101111111;
assign real_twiddle_register[27] = 16'b0000001000101100;
assign real_twiddle_register[28] = 16'b0000001011000100;
assign real_twiddle_register[29] = 16'b0000001101000000;
assign real_twiddle_register[30] = 16'b0000001110011100;
assign real_twiddle_register[31] = 16'b0000001111010101;
 

assign imag_twiddle_register[0] = 16'b0000000000000000;
assign imag_twiddle_register[1] = 16'b1111111100111101;
assign imag_twiddle_register[2] = 16'b1111111010000010;
assign imag_twiddle_register[3] = 16'b1111110111010101;
assign imag_twiddle_register[4] = 16'b1111110100111101;
assign imag_twiddle_register[5] = 16'b1111110011000001;
assign imag_twiddle_register[6] = 16'b1111110001100101;
assign imag_twiddle_register[7] = 16'b1111110000101100;
assign imag_twiddle_register[8] = 16'b1111110000011000;
assign imag_twiddle_register[9] = 16'b1111110000101100;
assign imag_twiddle_register[10] = 16'b1111110001100101;
assign imag_twiddle_register[11] = 16'b1111110011000001;
assign imag_twiddle_register[12] = 16'b1111110100111101;
assign imag_twiddle_register[13] = 16'b1111110111010101;
assign imag_twiddle_register[14] = 16'b1111111010000010;
assign imag_twiddle_register[15] = 16'b1111111100111101;
assign imag_twiddle_register[16] = 16'b0000000000000000;
assign imag_twiddle_register[17] = 16'b0000000011000100;
assign imag_twiddle_register[18] = 16'b0000000101111111;
assign imag_twiddle_register[19] = 16'b0000001000101100;
assign imag_twiddle_register[20] = 16'b0000001011000100;
assign imag_twiddle_register[21] = 16'b0000001101000000;
assign imag_twiddle_register[22] = 16'b0000001110011100;
assign imag_twiddle_register[23] = 16'b0000001111010101;
assign imag_twiddle_register[24] = 16'b0000001111101000;
assign imag_twiddle_register[25] = 16'b0000001111010101;
assign imag_twiddle_register[26] = 16'b0000001110011100;
assign imag_twiddle_register[27] = 16'b0000001101000000;
assign imag_twiddle_register[28] = 16'b0000001011000100;
assign imag_twiddle_register[29] = 16'b0000001000101100;
assign imag_twiddle_register[30] = 16'b0000000101111111;
assign imag_twiddle_register[31] = 16'b0000000011000100;



always_ff @( posedge clock or posedge reset ) begin : get_from_mem
    if(reset) begin
        real_twiddle <= real_twiddle_register[0];
        imag_twiddle <= imag_twiddle_register[0];
    end
    else begin
        real_twiddle <= real_twiddle_register[address];
        imag_twiddle <= imag_twiddle_register[address];
    end
end


endmodule