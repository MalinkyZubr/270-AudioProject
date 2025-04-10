`default_nettype none
//`include "../../hdl/fft/twiddle.sv"


module Twiddle32Tester();


logic clock = 0;
logic reset = 0;
logic[4:0] address = 5;
logic signed [15:0] real_twiddle, imag_twiddle;


Twiddle_Storage dut(
    .clock(clock),
    .reset(reset),
    .address(address),
    .real_twiddle(real_twiddle),
    .imag_twiddle(imag_twiddle)
);


initial begin
    #10 reset = 1;
    #10 reset = 0;

    address = 23;
    #10 clock = 1;
    #10 clock = 0;

    $display ("\n:%d", real_twiddle);
end

endmodule