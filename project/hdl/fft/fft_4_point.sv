`default_nettype none
`include "../structs.sv"

// should convert all registers to signed for FFT, considering signed twiddles

module FFT_4_Point #(
    parameter twiddle_size = TWIDDLE_SIZE, 
    input_size = SAMPLE_SIZE,
    calculation_size = CALCULATION_SIZE, // need to flatten the array
)
( // this is the base case
    input logic signed[4 * input_size - 1:0] input_real;

    output logic signed[4 * input_size - 1:0] output_real;
    output logic signed[4 * input_size - 1:0] output_imag;

    // general purpose
    input logic clock,
    input logic reset,
    input logic read
);

logic FFT_Unit_State state;
logic FFT_Unit_State next_state;




endmodule