module blinky (
    output logic LED0,
    input logic clk
);

    logic signed[32 * 8 - 1:0] in;
    logic signed [32 * 8 - 1:0] out;

    logic signed [512:0] something;

    assign something = 28904;

    assign in = 72;

    FFT_Top #(
        .sample_size(32), // how big is each real time domain sample?
        .buffer_size(8), // how many samples per bitstream are there to process?
        .twiddle_size(16),
        .no_float_mult(10)
    ) test (
        .input_bitstream(in),
        .output_bitstream(out)
    );

    always_ff @(posedge clk) begin
        in <= in + 1;
    end

    assign LED0 = in[0];
endmodule
