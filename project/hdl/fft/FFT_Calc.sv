`default_nettype none


module FFT_Calc #(
    parameter twiddle_size = 16, 
    sample_size = 32,
    is_base_case = 1'b1,
    no_float_mult = 1000
)
( // this is the base case
    input logic signed[sample_size - 1:0] even_input_real,
    input logic signed[sample_size - 1:0] odd_input_real,

    input logic signed[sample_size - 1:0] even_input_imag,
    input logic signed[sample_size - 1:0] odd_input_imag,

    input logic signed[twiddle_size - 1:0] twiddle_real,
    input logic signed[twiddle_size - 1:0] twiddle_imag,

    output logic signed[sample_size - 1:0] sum_term_real,
    output logic signed[sample_size - 1:0] sum_term_imag,

    output logic signed[sample_size - 1:0] diff_term_real,
    output logic signed[sample_size - 1:0] diff_term_imag
);

logic signed[sample_size - 1:0] even_input_real_buff;
logic signed[sample_size - 1:0] odd_input_real_buff;

logic signed[sample_size - 1:0] even_input_imag_buff;
logic signed[sample_size - 1:0] odd_input_imag_buff;

logic signed[sample_size - 1:0] q_odd_real;
logic signed[sample_size - 1:0] q_odd_imag;


// always_comb begin
//     if(is_base_case) begin
//         even_input_real_buff = even_input_real * no_float_mult;
//         even_input_imag_buff = even_input_imag * no_float_mult;
//     end
//     else begin
//         even_input_real_buff = even_input_real;
//         even_input_imag_buff = even_input_imag;
//     end
// end


assign even_input_real_buff = even_input_real * no_float_mult;
assign even_input_imag_buff = even_input_imag * no_float_mult;
    
assign odd_input_imag_buff = odd_input_imag; // why not multiplied by scaling factor?
assign odd_input_real_buff = odd_input_real; // because its already applied by the twiddle

assign q_odd_real = (odd_input_real_buff * twiddle_real) - (odd_input_imag_buff * twiddle_imag);
assign q_odd_imag = (odd_input_real_buff * twiddle_imag) + (odd_input_imag_buff * twiddle_real);

generate
    if(is_base_case) begin
        assign sum_term_real = even_input_real_buff + q_odd_real;
        assign sum_term_imag = even_input_imag_buff + q_odd_imag;

        assign diff_term_real = even_input_real_buff - q_odd_real;
        assign diff_term_imag = even_input_imag_buff - q_odd_imag;
    end
    else begin
        assign sum_term_real = (even_input_real_buff + q_odd_real) / no_float_mult;
        assign sum_term_imag = (even_input_imag_buff + q_odd_imag) / no_float_mult;

        assign diff_term_real = (even_input_real_buff - q_odd_real) / no_float_mult;
        assign diff_term_imag = (even_input_imag_buff - q_odd_imag) / no_float_mult;
    end
endgenerate

endmodule
