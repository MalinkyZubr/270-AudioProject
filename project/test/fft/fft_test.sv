`default_nettype none
`include "../../hdl/fft/twiddle.sv"


module FFTTester();

logic signed[buffer_size * sample_size - 1:0] input_bitstream;
logic signed[buffer_size * sample_size - 1:0] output_bitstream;


FFT_Top #(.sample_size(64), .buffer_size(32), .twiddle_size(16))fft(
    .input_bitstream(input_bitstream),
    .output_bitstream(output_bitstream)
);

endmodule