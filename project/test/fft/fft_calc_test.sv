`default_nettype none


module FFT_Calc_Tester #(
    parameter sample_size = 32,
    twiddle_size = 16
) 
();


logic signed[sample_size - 1:0] even_input_real;
logic signed[sample_size - 1:0] odd_input_real;

logic signed[sample_size - 1:0] even_input_imag;
logic signed[sample_size - 1:0] odd_input_imag;

logic signed[twiddle_size - 1:0] twiddle_real;
logic signed[twiddle_size - 1:0] twiddle_imag;

logic signed[sample_size - 1:0] sum_term_real;
logic signed[sample_size - 1:0] sum_term_imag;

logic signed[sample_size - 1:0] diff_term_real;
logic signed[sample_size - 1:0] diff_term_imag;

logic signed[sample_size - 1:0] sum_term_real_nobase;
logic signed[sample_size - 1:0] sum_term_imag_nobase;

logic signed[sample_size - 1:0] diff_term_real_nobase;
logic signed[sample_size - 1:0] diff_term_imag_nobase;

assign twiddle_real = 5;
assign twiddle_imag = 7;

FFT_Calc #(.sample_size(32), .twiddle_size(16), .no_float_mult(1000))fft(
    .even_input_real(even_input_real),
    .even_input_imag(even_input_imag),
    .odd_input_real(odd_input_real),
    .odd_input_imag(odd_input_imag),

    .twiddle_real(twiddle_real),
    .twiddle_imag(twiddle_imag),
    
    .sum_term_real(sum_term_real),
    .sum_term_imag(sum_term_imag),

    .diff_term_real(diff_term_real),
    .diff_term_imag(diff_term_imag)
);

FFT_Calc #(.sample_size(32), .twiddle_size(16), .no_float_mult(1000), .is_base_case(0))fft_nobase(
    .even_input_real(even_input_real),
    .even_input_imag(even_input_imag),
    .odd_input_real(odd_input_real),
    .odd_input_imag(odd_input_imag),

    .twiddle_real(twiddle_real),
    .twiddle_imag(twiddle_imag),
    
    .sum_term_real(sum_term_real_nobase),
    .sum_term_imag(sum_term_imag_nobase),

    .diff_term_real(diff_term_real_nobase),
    .diff_term_imag(diff_term_imag_nobase)
);

// genvar i;

// generate
//     for(i = 0; i < 32; i = i + 1) begin
//         input_bitstream[i * 32 + 32 - 1: i * 32] = $sin(i);
//     end
// endgenerate

initial begin
    even_input_real = 10;
    even_input_imag = 15;
    odd_input_real = 20;
    odd_input_imag = 25;
    $display("CALC TESTS\n");
    #10;
    $display("low_index: %0d + %0di, high_index: %0d + %0di\n", sum_term_real, sum_term_imag, diff_term_real, diff_term_imag);
    #10;
    even_input_real = 10000;
    even_input_imag = 15000;
    odd_input_real = 20000;
    odd_input_imag = 25000;
    #10;
    $display("low_index: %0d + %0di, high_index: %0d + %0di\n", sum_term_real_nobase, sum_term_imag_nobase, diff_term_real_nobase, diff_term_imag_nobase);
    $display("==========================\n");
end

endmodule