`default_nettype none


module FFT_Butterfly_Tester #(
    parameter twiddle_size = 16,
    buffer_size = 32,
    sample_size = 32
)
();

logic signed[(buffer_size * sample_size / 2) - 1:0] even_fft_real;
logic signed[(buffer_size * sample_size / 2) - 1:0] even_fft_imag;

logic signed[(buffer_size * sample_size / 2) - 1:0] odd_fft_real;
logic signed[(buffer_size * sample_size / 2) - 1:0] odd_fft_imag;

logic signed[(twiddle_size * buffer_size / 2) - 1:0] twiddles_real;
logic signed[(twiddle_size * buffer_size / 2) - 1:0] twiddles_imag;

logic signed[buffer_size * sample_size - 1:0] output_real;
logic signed[buffer_size * sample_size - 1:0] output_imag;


Twiddle_Coordinator #(
    .buffer_size(buffer_size),
    .twiddle_size(twiddle_size)
) twiddles(
    .real_twiddles(twiddles_real),
    .imag_twiddles(twiddles_imag)
);


FFT_Butterfly #(
    .twiddle_size(twiddle_size),
    .buffer_size(buffer_size),
    .sample_size(sample_size),
    .no_float_mult(1000)
) butterfly_dut (
    .even_fft_real(even_fft_real),
    .even_fft_imag(even_fft_imag),
    .odd_fft_real(odd_fft_real),
    .odd_fft_imag(odd_fft_imag),
    .twiddles_real(twiddles_real),
    .twiddles_imag(twiddles_imag),
    .output_real(output_real),
    .output_imag(output_imag)
);

initial begin
    int in_e_r;
    int in_e_i;
    int in_o_r;
    int in_o_i;

    int out_r;
    int out_i;
    int butterfly;

    $display("BUTTERFLY TESTS\n");

    for(int i = 0; i < buffer_size / 2; i = i + 1) begin
        even_fft_real[i * sample_size +: sample_size] = i + 4;
        even_fft_imag[i * sample_size +: sample_size] = i + 1;

        odd_fft_real[i * sample_size +: sample_size] = i + 2;
        odd_fft_imag[i * sample_size +: sample_size] = i + 5;

        $display("Even: %0d + %0dj, Odd: %0d + %0dj\n", 
            even_fft_real[i * sample_size +: sample_size],
            even_fft_imag[i * sample_size +: sample_size],
            odd_fft_real[i * sample_size +: sample_size],
            odd_fft_imag[i * sample_size +: sample_size]
        );
        #10;
        //$display("ValueR: %b\n", output_real);
        //$display("ValueI: %b\n",output_imag);
        //$display("Twiddle: %0d + ");
    end
    //$display("%0b\n%0b\n%0b\n%0b\n", even_fft_real, even_fft_imag, odd_fft_real, odd_fft_imag);
    #100;
    //$display("Real: %0b\nImag: %0b\n", output_real, output_imag);

    for(int a = 0; a < buffer_size; a = a + 1) begin
        out_r = output_real[a * sample_size +: sample_size];
        out_i = output_imag[a * sample_size +: sample_size];
        //$display("Value: %0d + %0dj\n", out_r, out_i);
    end

    $display("==========================\n");
end

endmodule