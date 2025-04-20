`default_nettype none

module FFT_Top #(
    parameter sample_size = 32, // how big is each real time domain sample?
    buffer_size = 32, // how many samples per bitstream are there to process?
    twiddle_size = 16,
    no_float_mult = 1000
)
(
    input logic signed[buffer_size * sample_size - 1:0] input_bitstream, // input time domain bitstream
    output logic signed[buffer_size * sample_size - 1:0] output_bitstream // magnitudes of all calculated frequency bins
    // output bitstream is PARTIAL magnitude. The square root hasnt been applied
);

    logic signed[buffer_size * sample_size - 1:0] fft_real;
    logic signed[buffer_size * sample_size - 1:0] fft_imag;

    logic signed[(buffer_size * twiddle_size / 2) - 1:0] twiddles_real;
    logic signed[(buffer_size * twiddle_size / 2) - 1:0] twiddles_imag;

    Twiddle_Storage twiddles(
        .real_twiddles(twiddles_real),
        .imag_twiddles(twiddles_imag)
    );

    FFT_N_Point #(.buffer_size(buffer_size),
        .twiddle_size(twiddle_size),
        .num_twiddles(buffer_size / 2),
        .sample_size(sample_size),
        .no_float_mult(no_float_mult)
    ) inst_n_fft (
        .input_real(input_bitstream),

        .output_real(fft_real),
        .output_imag(fft_imag),

        .twiddles_real(twiddles_real),
        .twiddles_imag(twiddles_imag)
    );

    Partial_Magnitude_Computer #(
        .sample_size(sample_size),
        .buffer_size(buffer_size)
    ) inst_p_mag (
        .input_real(fft_real),
        .input_imag(fft_imag),
        .output_mags(output_bitstream)
    );

endmodule