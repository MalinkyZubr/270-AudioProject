module FFT_Butterfly #(
    parameter twiddle_size = 16, 
    buffer_size = 32,
    sample_size = 32,
    no_float_mult = 1000
)
(
    input logic signed[(buffer_size * sample_size / 2) - 1:0] even_fft_real,
    input logic signed[(buffer_size * sample_size / 2) - 1:0] even_fft_imag,

    input logic signed[(buffer_size * sample_size / 2) - 1:0] odd_fft_real,
    input logic signed[(buffer_size * sample_size / 2) - 1:0] odd_fft_imag,

    input logic signed[(twiddle_size * buffer_size / 2) - 1:0] twiddles_real,
    input logic signed[(twiddle_size * buffer_size / 2) - 1:0] twiddles_imag,

    output logic signed[buffer_size * sample_size - 1:0] output_real,
    output logic signed[buffer_size * sample_size - 1:0] output_imag
);

genvar loop_index;

logic signed[buffer_size * sample_size - 1:0] output_real_buff;
logic signed[buffer_size * sample_size - 1:0] output_imag_buff;

generate
    for(loop_index = 0; loop_index < buffer_size / 2; loop_index = loop_index + 1) begin
        logic signed[twiddle_size - 1:0] twiddle_calc_real;
        logic signed[twiddle_size - 1:0] twiddle_calc_imag;

        logic signed[sample_size - 1:0] even_fft_real_in;
        logic signed[sample_size - 1:0] even_fft_imag_in;
        logic signed[sample_size - 1:0] odd_fft_real_in;
        logic signed[sample_size - 1:0] odd_fft_imag_in;

        logic signed[sample_size - 1:0] sum_term_real_out;
        logic signed[sample_size - 1:0] sum_term_imag_out;
        logic signed[sample_size - 1:0] diff_term_real_out;
        logic signed[sample_size - 1:0] diff_term_imag_out;

        assign twiddle_calc_real = twiddles_real[loop_index * twiddle_size+:twiddle_size];
        assign twiddle_calc_imag = twiddles_imag[loop_index * twiddle_size+:twiddle_size];

        assign even_fft_real_in = even_fft_real[loop_index * sample_size+:sample_size];
        assign odd_fft_real_in = odd_fft_real[loop_index * sample_size+:sample_size];

        assign even_fft_imag_in = even_fft_imag[loop_index * sample_size+:sample_size];
        assign odd_fft_imag_in = odd_fft_imag[loop_index * sample_size+:sample_size];

        FFT_Calc #(.twiddle_size(twiddle_size),
            .sample_size(sample_size),
            .is_base_case(1'b0))
        instn_point_calc (
            .even_input_real(even_fft_real_in),
            .even_input_imag(even_fft_imag_in),
            .odd_input_real(odd_fft_real_in),
            .odd_input_imag(odd_fft_imag_in),

            .twiddle_real(twiddle_calc_real),
            .twiddle_imag(twiddle_calc_imag),

            .sum_term_real(sum_term_real_out),
            .sum_term_imag(sum_term_imag_out),
            .diff_term_real(diff_term_real_out),
            .diff_term_imag(diff_term_imag_out)
        );

        always_comb begin
            output_real_buff[loop_index * sample_size+:sample_size] = sum_term_real_out;
            output_real_buff[(((loop_index * sample_size) + (buffer_size * sample_size / 2)))+:sample_size] = diff_term_real_out;

            output_imag_buff[loop_index * sample_size+:sample_size] = sum_term_imag_out;
            output_imag_buff[(((loop_index * sample_size) + (buffer_size * sample_size / 2)))+:sample_size] = diff_term_imag_out;
        end
    end
endgenerate

assign output_real = output_real_buff;
assign output_imag = output_imag_buff;

endmodule