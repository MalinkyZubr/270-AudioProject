`default_nettype none

`ifndef fft_calc
`define fft_calc

// `include "./twiddle.sv"
`include "constants.sv"
// should convert all registers to signed for FFT, considering signed twiddles

module FFT_Calc #(
    parameter twiddle_size = TWIDDLE_SIZE, 
    sample_size = SAMPLE_SIZE,
    is_base_case = 1'b1
)
( // this is the base case
    input logic signed[sample_size - 1:0] even_input_real,
    input logic signed[sample_size - 1:0] odd_input_real,

    input logic signed[sample_size - 1:0] even_input_imag,
    input logic signed[sample_size - 1:0] odd_input_imag,

    input logic signed[twiddle_size - 1:0] twiddle_real,
    input logic signed[twiddle_size - 1:0] twiddle_imag,

    output logic signed[sample_size - 1:0] sum_term_real,
    output logic signed[sample_size - 1:0] sum_term_imag,

    output logic signed[sample_size - 1:0] diff_term_real,
    output logic signed[sample_size - 1:0] diff_term_imag
);

logic signed[sample_size - 1:0] even_input_real_buff;
logic signed[sample_size - 1:0] odd_input_real_buff;

logic signed[sample_size - 1:0] even_input_imag_buff;
logic signed[sample_size - 1:0] odd_input_imag_buff;

logic signed[sample_size - 1:0] q_odd_real;
logic signed[sample_size - 1:0] q_odd_imag;


assign even_input_real_buff = even_input_real * NOFLOAT_MULTIPLIER;
assign even_input_imag_buff = even_input_imag * NOFLOAT_MULTIPLIER;
    
assign odd_input_imag_buff = odd_input_imag;
assign odd_input_real_buff = odd_input_real;

assign q_odd_real = (odd_input_real_buff * twiddle_real) - (odd_input_imag_buff * twiddle_imag);
assign q_odd_imag = (odd_input_real_buff * twiddle_imag) + (odd_input_imag_buff * twiddle_real);

generate
    if(is_base_case) begin
        assign sum_term_real = even_input_real_buff + q_odd_real;
        assign sum_term_imag = even_input_imag_buff + q_odd_imag;

        assign diff_term_real = even_input_real_buff - q_odd_real;
        assign diff_term_imag = even_input_imag_buff - q_odd_imag;
    end
    else begin
        assign sum_term_real = (even_input_real_buff + q_odd_real) / NOFLOAT_MULTIPLIER;
        assign sum_term_imag = (even_input_imag_buff + q_odd_imag) / NOFLOAT_MULTIPLIER;

        assign diff_term_real = (even_input_real_buff - q_odd_real) / NOFLOAT_MULTIPLIER;
        assign diff_term_imag = (even_input_imag_buff - q_odd_imag) / NOFLOAT_MULTIPLIER;
    end
endgenerate

endmodule

`endif