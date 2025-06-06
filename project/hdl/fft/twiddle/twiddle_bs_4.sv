`default_nettype none

// DO NOT CHANGE ME. I AM AN AUTOGENERATED FILE

//-----------------------------------------------------------------------------
//  File       : twiddle.sv
//  Author     : Michael Ray
//  Created    : <2025-04-20>
//  Description: 
//      Stores the twiddle factors for an n point radix 2 fft
//
//  Parameters: None 
//
//  Ports:
//      Outputs:
//          - real_twiddles : array representing real components of twiddle factors
//          - imag_twiddles : array representing imaginary components of twiddle factors
//
//  Notes:
//      Do not attempt to modify this file. It was generated by the python script in the build module, "build.py"
//
//-----------------------------------------------------------------------------
module Twiddle_Storage_4 (
    output logic signed[16 * 2 - 1:0] real_twiddles,
    output logic signed[16 * 2 - 1:0] imag_twiddles
);

assign real_twiddles[15:0] = 16'b0000000001100100;
assign real_twiddles[31:16] = 16'b0000000000000000;
 

assign imag_twiddles[15:0] = 16'b0000000000000000;
assign imag_twiddles[31:16] = 16'b1111111110011100;


endmodule