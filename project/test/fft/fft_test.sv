`default_nettype none

module FFTTester();

logic signed[32 * 32 - 1:0] input_bitstream;
logic signed[32 * 32 - 1:0] output_bitstream;

FFT_Top #(.sample_size(32), .buffer_size(32), .twiddle_size(16), .no_float_mult(1000))fft(
    .input_bitstream(input_bitstream),
    .output_bitstream(output_bitstream)
);

// genvar i;

// generate
//     for(i = 0; i < 32; i = i + 1) begin
//         input_bitstream[i * 32 + 32 - 1: i * 32] = $sin(i);
//     end
// endgenerate

initial begin
    int out;
    int in;

    $display("FFT TESTS\n");
    
    for(int i = 0; i < 32; i = i + 1) begin
        input_bitstream[i * 32 +: 32] = 10 * $sin(i);
    end

    #10;

    for(int a = 0; a < 32; a = a + 1) begin
        out = output_bitstream[a * 32 +: 32];
        in = input_bitstream[a * 32 +: 32];
        $display("%0d: Val: %0d Mag: %0d\n", a, in, out);
    end

    $display("==========================\n");
end

endmodule