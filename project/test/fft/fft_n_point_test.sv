`default_nettype none

module InternalTester #(
    parameter i = 2,
    sample_size = 32,
    no_float_mult = 1000
)
();


logic signed[i * sample_size - 1:0] input_bitstream;
logic signed[i * sample_size - 1:0] output_real;
logic signed[i * sample_size - 1:0] output_imag;

logic signed[(i * 16 / 2) - 1:0] twiddles_real;
logic signed[(i * 16 / 2) - 1:0] twiddles_imag;

Twiddle_Coordinator #(.buffer_size(i), .twiddle_size(16)) twiddles(
    .real_twiddles(twiddles_real),
    .imag_twiddles(twiddles_imag)
);

FFT_N_Point #(.sample_size(sample_size), .buffer_size(i), .twiddle_size(16), .no_float_mult(no_float_mult))fft(
    .input_real(input_bitstream),
    .output_real(output_real),
    .output_imag(output_imag)
);

initial begin
    int out_r;
    int out_i;
    int in;

    //$display("FFT N = %0d TESTS\n", i);
    
    for(int j = 0; j < i; j = j + 1) begin
        //$display("%f", 1000 * $sin(2 * j));
        //input_bitstream[j * 32 +: 32] = 10 * $sin(j * 15000) + 20 * $cos(j * 4000) + 10 * $cos(j * 5000) + 50 *$cos(j * 18000) + 40 * $cos(j * 400);
        input_bitstream[j * sample_size +: sample_size] = 10 * $sin(j * 15000) + 20* $cos(j * 4000) + 10 * $cos(j * 5000) + $cos(j * 18000) + $cos(j * 400);
    end

    #10;
    #100;
    for(int a = 0; a < i; a = a + 1) begin
        out_r = output_real[a * sample_size +: sample_size];
        out_i = output_imag[a * sample_size +: sample_size];
        in = input_bitstream[a * sample_size +: sample_size];
        $display("%0d,%0d", out_r, out_i);
    end

    //$display("==========================\n");
end

endmodule

module FFTTester();

InternalTester #(.i(16), .sample_size(32), .no_float_mult(256)) test();

endmodule