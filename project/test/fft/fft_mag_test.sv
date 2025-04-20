`default_nettype none


module FFT_Calc_Tester #(
    parameter sample_size = 32,
    twiddle_size = 16
) 
();


logic signed[4 * 32 - 1:0] input_real;
logic signed[4 * 32 - 1:0] input_imag;
logic signed[4 * 32 - 1:0] output_mag;


Partial_Magnitude_Computer #(.sample_size(32), .buffer_size(4)) magtest(
    .input_real(input_real),
    .input_imag(input_imag),
    .output_mags(output_mag)
);

// genvar i;

// generate
//     for(i = 0; i < 32; i = i + 1) begin
//         input_bitstream[i * 32 + 32 - 1: i * 32] = $sin(i);
//     end
// endgenerate

initial begin
    int out;
    int in_r;
    int in_i;

    $display("MAGNITUDE TESTS\n");

    for(int i = 0; i < 4; i = i + 1) begin
        input_real[i * 32 +: 32] = i;
        input_imag[i * 32 +: 32] = 10 - i;
    end
    #10;
    for(int a = 0; a < 4; a = a + 1) begin
        out = output_mag[a * 32 +: 32];
        in_r = input_real[a * 32 +: 32];
        in_i = input_imag[a * 32 +: 32];
        $display("Val: %0d + %0di, wanted: %0d got %0d\n", in_r, in_i, (in_r * in_r) + (in_i * in_i), out);
    end
    $display("==========================\n");
end

endmodule