`default_nettype none


module Twiddle_Storage (
    input logic clock,
    input logic reset,
    input logic[{{ address_size }}:0] address,
    output logic signed[{{ twiddle_size }}:0] real_twiddle,
    output logic signed[{{ twiddle_size }}:0] imag_twiddle
);

reg signed[{{ twiddle_size }}:0] real_twiddle_register [{{ buffer_size }}:0];
reg signed[{{ twiddle_size }}:0] imag_twiddle_register [{{ buffer_size }}:0];

{{real_twiddles}} 

{{imag_twiddles}}


always_ff @( posedge clock or posedge reset ) begin : get_from_mem
    if(reset) begin
        real_twiddle <= real_twiddle_register[0];
        imag_twiddle <= imag_twiddle_register[0];
    end
    else begin
        real_twiddle <= real_twiddle_register[address];
        imag_twiddle <= imag_twiddle_register[address];
    end
end


endmodule