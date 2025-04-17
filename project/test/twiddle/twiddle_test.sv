`default_nettype none
//`include "../../hdl/fft/twiddle.sv"


module Twiddle32Tester();


logic signed[16 * 16 - 1:0] real_twiddle, imag_twiddle;


Twiddle_Storage dut(
    .real_twiddles(real_twiddle),
    .imag_twiddles(imag_twiddle)
);


initial begin
    for(int index = 0; index < 16; index++) begin
        #10;
        $display ("\n%0d + %0dj", $signed(real_twiddle[index * 16+:16]), $signed(imag_twiddle[index * 16+:16]));
    end
end

endmodule