`default_nettype none
`include "../structs.sv"

// should convert all registers to signed for FFT, considering signed twiddles

module FFT_Calc #(
    parameter twiddle_size = TWIDDLE_SIZE, 
    input_size = SAMPLE_SIZE,
    calculation_size = CALCULATION_SIZE, // need to flatten the array
)
( // this is the base case
    input logic signed[input_size - 1:0] even_input_real,
    input logic signed[input_size - 1:0] odd_input_real,

    input logic signed[input_size - 1:0] even_input_imag,
    input logic signed[input_size - 1:0] odd_input_imag,

    input logic signed[twiddle_size - 1:0] twiddle_real,
    input logic signed[twiddle_size - 1:0] twiddle_imag,

    output logic signed[calculation_size - 1:0] sum_term_real,
    output logic signed[calculation_size - 1:0] sum_term_imag,

    output logic signed[calculation_size - 1:0] diff_term_real,
    output logic signed[calculation_size - 1:0] diff_term_imag,

    // general purpose
    input logic clock,
    input logic reset,
    input logic read,
    output logic done
);

logic signed[input_size - 1:0] even_input_real_buff,
logic signed[input_size - 1:0] odd_input_real_buff,

logic signed[input_size - 1:0] even_input_imag_buff,
logic signed[input_size - 1:0] odd_input_imag_buff,

logic FFT_Unit_State state;
logic FFT_Unit_State next_state;

logic signed[calculation_size - 1:0] q_odd_real;
logic signed[calculation_size - 1:0] q_odd_imag;


always_comb begin
    if(state == READING) begin
        even_input_real_buff = even_input_real;
        even_input_imag_buff = even_input_imag;
        
        odd_input_imag_buff = odd_input_imag;
        odd_input_real_buff = odd_input_real;

        next_state = COMPUTING;
    end
    else if(state == COMPUTING) begin
        q_odd_real = (odd_input_real_buff * twiddle_real) - (odd_input_imag_buff * twiddle_imag);
        q_odd_imag = (odd_input_real_buff * twiddle_imag) + (odd_input_imag_buff * twiddle_real);
        sum_term_real = even_input_real_buff + q_odd_real;
        sum_term_imag = even_input_imag_buff + q_odd_imag;

        diff_term_real = even_input_real_buff - q_odd_real;
        diff_term_imag = even_input_imag_buff - q_odd_imag;

        next_state = DONE;
    end
end

always_ff @( posedge clock or posedge reset ) begin : get_from_mem
    if(reset && state == DONE) begin
        state <= READING;
    end
    else begin
        state <= next_state;
    end

    if(state == DONE) begin
        done <= 1'b1;
    end
    else begin
        done <= 1'b0;
    end
end

endmodule