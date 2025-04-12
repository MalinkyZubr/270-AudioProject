`default_nettype none
`include "../structs.sv"

// should convert all registers to signed for FFT, considering signed twiddles

module FFT_2_Point #(parameter )
( // this is the base case
    input logic signed[] even_input_real,
    input logic signed[] odd_input_real,

    input logic signed[] even_input_imag,
    input logic signed[] odd_input_imag,

    input logic signed[] twiddle_real,
    input logic signed[] twiddle_imag,

    output logic signed[] sum_term_real,
    output logic signed[] sum_term_imag,

    output logic signed[] diff_term_real,
    output logic signed[] diff_term_imag,

    // general purpose
    input logic enable,
    input logic clock,
    input logic reset,
    output logic done
);

assign FFT_Unit_State state = IDLE;
assign FFT_Unit_State next_state = COMPUTING;

assign internal_doneflag;

always_comb begin
    if(state == COMPUTING) begin
        sum_term_real = even_input_real + odd_input_real;
        sum_term_imag = even_input_imag + odd_input_imag;

        diff_term_real = even_input_real - odd_input_real;
        diff_term_imag = even_input_imag - odd_input_imag;
    end
end

endmodule