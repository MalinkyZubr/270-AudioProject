`default_nettype none

module InternalTester #(
    parameter i = 2
)
();


logic signed[i * 32 - 1:0] input_bitstream;
logic signed[i * 32 - 1:0] output_real;
logic signed[i * 32 - 1:0] output_imag;

logic signed[16 * 16 - 1:0] twiddles_real;
logic signed[16 * 16 - 1:0] twiddles_imag;

Twiddle_Storage twiddles(
    .real_twiddles(twiddles_real),
    .imag_twiddles(twiddles_imag)
);

FFT_N_Point #(.sample_size(32), .buffer_size(i), .twiddle_size(16), .no_float_mult(1000), .num_twiddles(16))fft(
    .input_real(input_bitstream),
    .output_real(output_real),
    .output_imag(output_imag),
    .twiddles_real(twiddles_real),
    .twiddles_imag(twiddles_imag)
);

initial begin
    int out_r;
    int out_i;
    int in;

        $display("FFT N = %0d TESTS\n", i);
        
        for(int j = 0; j < i; j = j + 1) begin
            input_bitstream[j * 32 +: 32] = 1000 * $sin(j);
        end

        #10;

        for(int a = 0; a < i; a = a + 1) begin
            out_r = output_real[a * 32 +: 32];
            out_i = output_imag[a * 32 +: 32];
            in = input_bitstream[a * 32 +: 32];
            #10 ;
            $display("Input %0d: Out: %0d + %0di\n", in, out_r, out_i);
        end

        $display("==========================\n");
    end

endmodule

module FFTTester();

genvar i;

InternalTester #(.i(4)) test();

endmodule