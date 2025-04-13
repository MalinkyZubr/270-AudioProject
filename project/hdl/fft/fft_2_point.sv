`default_nettype none
`include "../structs.sv"

// should convert all registers to signed for FFT, considering signed twiddles

module FFT_2_Point #(
    parameter twiddle_size = TWIDDLE_SIZE, 
    num_twiddles = BUFFER_SIZE,
    input_size = SAMPLE_SIZE,
    num_samples = 2,
    calculation_size = CALCULATION_SIZE, // need to flatten the array
)
( // this is the base case
    input logic signed[2 * input_size - 1:0] input_real;

    output logic signed[2 * input_size - 1:0] output_real;
    output logic signed[2 * input_size - 1:0] output_imag;

    input logic signed[twiddle_size * num_twiddles - 1:0] twiddles_real,
    input logic signed[twiddle_size * num_twiddles - 1:0] twiddles_imag,
    
    // general purpose
    input logic clock,
    input logic reset,
    input logic read,
    output logic done,
);

logic signed[2 * input_size - 1:0] output_real_buff;
logic signed[2 * input_size - 1:0] output_imag_buff;

FFT_Calc calc_2_point = FFT_Calc(
    .even_input_real(input_real[input_size - 1:0]),
    .odd_input_real(input_real[2 * input_size - 1:input_size]),
    .even_input_imag(0),
    .odd_input_imag(0),
    .twiddle_real(twiddle_real),
    .twiddle_imag(twiddle_imag),
    .sum_term_real(output_real[input_size - 1:0]),
    .diff_term_real(output_real[2 * input_size - 1:input_size]),
    .sum_term_imag(output_imag[input_size - 1:0]),
    .diff_term_imag(output_imag[2 * input_size - 1:input_size]),
    .clock(clock),
    .reset(reset),
    .read(read),
    .done(done)
);

endmodule