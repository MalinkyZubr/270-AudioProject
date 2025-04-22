module FFT_Base_Butterfly #(
    parameter twiddle_size = 16, 
    sample_size = 32,
    no_float_mult = 1000
)
(
    input logic signed[sample_size - 1:0] even_buffer,
    input logic signed[sample_size - 1:0] odd_buffer,

    input logic signed[twiddle_size - 1:0] twiddles_real,
    input logic signed[twiddle_size - 1:0] twiddles_imag,

    output logic signed[2 * sample_size - 1:0] output_real,
    output logic signed[2 * sample_size - 1:0] output_imag
);

    logic signed[2 * sample_size - 1:0] output_real_buff;
    logic signed[2 * sample_size - 1:0] output_imag_buff;

    logic signed[sample_size - 1:0] output_real_sum_buff;
    logic signed[sample_size - 1:0] output_real_diff_buff;
    logic signed[sample_size - 1:0] output_imag_sum_buff;
    logic signed[sample_size - 1:0] output_imag_diff_buff;

    logic signed[twiddle_size - 1:0] twiddle_calc_real_2;
    logic signed[twiddle_size - 1:0] twiddle_calc_imag_2;

    assign twiddle_calc_real_2 = twiddles_real[twiddle_size - 1:0];
    assign twiddle_calc_imag_2 = twiddles_imag[twiddle_size - 1:0];

    FFT_Calc #(.twiddle_size(twiddle_size),
        .sample_size(sample_size),
        .is_base_case(1'b1))
    inst_2_point_fft_calc (
        .even_input_real(even_buffer),
        .odd_input_real(odd_buffer),
        .even_input_imag(0),
        .odd_input_imag(0),

        .twiddle_real(twiddle_calc_real_2),
        .twiddle_imag(twiddle_calc_imag_2),

        .sum_term_real(output_real_sum_buff),
        .diff_term_real(output_real_diff_buff),
        .sum_term_imag(output_imag_sum_buff),
        .diff_term_imag(output_imag_diff_buff)
    );

    assign output_real_buff[sample_size - 1:0] = output_real_sum_buff;
    assign output_real_buff[(2 * sample_size) - 1:sample_size] = output_real_diff_buff;
    assign output_imag_buff[sample_size - 1:0] = output_imag_sum_buff;
    assign output_imag_buff[(2 * sample_size) - 1:sample_size] = output_imag_diff_buff;

    assign output_real = output_real_buff;
    assign output_imag = output_imag_buff;
endmodule