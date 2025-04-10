`default_nettype none


module Twiddle_Storage (
    output logic[{{ twiddle_size }}:0] real_twiddle_register [{{ buffer_size }}:0],
    output logic[{{ twiddle_size }}:0] imag_twiddle_register [{{ buffer_size }}:0]
);

assign real_twiddle_register = 
    { 
{{real_twiddles}} 
    };

assign imag_twiddle_register = 
    { 
{{imag_twiddles}} 
    };

endmodule