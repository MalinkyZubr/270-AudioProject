`default_nettype none

// DO NOT CHANGE ME. I AM AN AUTOGENERATED FILE
module Twiddle_Storage (
    output logic signed[{{ twiddle_size }} - 1:0] real_twiddles,
    output logic signed[{{ twiddle_size }} - 1:0] imag_twiddles
);

reg signed[{{ twiddle_size }} * {{ buffer_size }} - 1:0] real_twiddle_register;
reg signed[{{ twiddle_size }} * {{ buffer_size }} - 1:0] imag_twiddle_register;

{{real_twiddles}} 

{{imag_twiddles}}

endmodule