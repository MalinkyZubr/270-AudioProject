`default_nettype none


module FFT_Breakdown_Tester ();


logic signed[32 * 32 - 1:0] input_real;
logic signed[16 * 32 - 1:0] output_even;
logic signed[16 * 32 - 1:0] output_odd;


FFT_Breakdown #(.buffer_size(32), .sample_size(32)) breakdown_dut (
    .input_real(input_real),
    .output_even(output_even),
    .output_odd(output_odd)
);

// genvar i;

// generate
//     for(i = 0; i < 32; i = i + 1) begin
//         input_bitstream[i * 32 + 32 - 1: i * 32] = $sin(i);
//     end
// endgenerate

initial begin
    int out;
    int in_e;
    int in_o;

    $display("BREAKDOWN TESTS\n");

    for(int i = 0; i < 32; i = i + 1) begin
        input_real[i * 32 +: 32] = i;
    end
    #10;
    for(int a = 0; a < 16; a = a + 1) begin
        in_e = output_even[a * 32 +: 32];
        in_o = output_odd[a * 32 +: 32];
        $display("Even: %0d, Odd: %0d", in_e, in_o);
    end
    $display("==========================\n");
end

endmodule