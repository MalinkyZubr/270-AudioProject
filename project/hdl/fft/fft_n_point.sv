`default_nettype none

`ifndef fft_n_point
`define fft_n_point

// `include "./twiddle.sv"
// `include "./fft_calc.sv"
`include "constants.sv"

// should convert all registers to signed for FFT, considering signed twiddles

module FFT_N_Point #(
    parameter twiddle_size = TWIDDLE_SIZE, 
    num_twiddles = BUFFER_SIZE / 2,
    buffer_size = 2,
    sample_size = SAMPLE_SIZE
)
( // this is the base case
    input logic signed[buffer_size * sample_size - 1:0] input_real,

    output logic signed[buffer_size * sample_size - 1:0] output_real,
    output logic signed[buffer_size * sample_size - 1:0] output_imag,

    input logic signed[twiddle_size * num_twiddles - 1:0] twiddles_real,
    input logic signed[twiddle_size * num_twiddles - 1:0] twiddles_imag
);
 // standardize for multi radix later
genvar loop_index;

logic signed[((buffer_size * sample_size) / 2) - 1] even_buffer;
logic signed[((buffer_size * sample_size) / 2) - 1] odd_buffer;

logic signed[((buffer_size * sample_size) / 2) - 1] even_fft_real;
logic signed[((buffer_size * sample_size) / 2) - 1] even_fft_imag;

logic signed[((buffer_size * sample_size) / 2) - 1] odd_fft_real;
logic signed[((buffer_size * sample_size) / 2) - 1] odd_fft_imag;

logic signed[buffer_size * sample_size - 1:0] output_real_buff;
logic signed[buffer_size * sample_size - 1:0] output_imag_buff;

generate
    if((buffer_size & (buffer_size - 1)) != 0 || buffer_size < 2) begin
        initial begin
            $fatal("Buffsize error");
        end
    end
    for(loop_index = 0; loop_index < buffer_size; loop_index = loop_index + 2) begin
        assign even_buffer[((loop_index / 2) * sample_size) + sample_size - 1 : (loop_index / 2) * sample_size] = 
            input_real[(loop_index * sample_size) + sample_size - 1 : loop_index * sample_size];

        assign odd_buffer[((loop_index / 2) * sample_size) + sample_size - 1 : (loop_index / 2) * sample_size] = 
            input_real[((loop_index + 1) * sample_size) + sample_size - 1 : (loop_index + 1) * sample_size];
    end

    if(buffer_size == 2) begin
        FFT_Calc #(.twiddle_size(twiddle_size),
            .sample_size(sample_size),
            .is_base_case(1'b1))
        inst_2_point_fft_calc (
            .even_input_real(even_buffer),
            .odd_input_real(odd_buffer),
            .even_input_imag(0),
            .odd_input_imag(0),

            .twiddle_real(twiddle_real),
            .twiddle_imag(twiddle_imag),

            .sum_term_real(output_real_buff[sample_size - 1:0]),
            .diff_term_real(output_real_buff[(2 * sample_size) - 1:sample_size]),
            .sum_term_imag(output_imag_buff[sample_size - 1:0]),
            .diff_term_imag(output_imag_buff[(2 * sample_size) - 1:sample_size])
        );
    end

    else if ((buffer_size & (buffer_size - 1)) == 0 && buffer_size > 2) begin // stnadardize later for different radicies
        FFT_N_Point #(.buffer_size(buffer_size / 2), 
            .twiddle_size(twiddle_size), 
            .num_twiddles(num_twiddles), 
            .sample_size(sample_size)) 
            inst_even_child (
                .input_real(even_buffer),
                .output_real(even_fft_real),
                .output_imag(even_fft_imag),

                .twiddles_real(twiddles_real),
                .twiddles_imag(twiddles_imag)
            );

        FFT_N_Point #(.buffer_size(buffer_size / 2), 
            .twiddle_size(twiddle_size), 
            .num_twiddles(num_twiddles), 
            .sample_size(sample_size)) 
            inst_odd_child (
                .input_real(odd_buffer),
                .output_real(odd_fft_real),
                .output_imag(odd_fft_imag),

                .twiddles_real(twiddles_real),
                .twiddles_imag(twiddles_imag)
            );

        for(loop_index = 0; loop_index < buffer_size / 2; loop_index = loop_index + 1) begin
            localparam int upper_calc_index = (sample_size * loop_index) + sample_size - 1;
            localparam int lower_calc_index = sample_size * loop_index;
            localparam int lower_twiddle_index = (twiddle_size * loop_index) + twiddle_size - 1; // caalculation size computation should be done taking into account twiddle size as well
            localparam int upper_twiddle_index = twiddle_size * loop_index;

            FFT_Calc #(.twiddle_size(twiddle_size),
                .sample_size(sample_size),
                .is_base_case(1'b0))
            instn_point_calc (
                .even_input_real(even_fft_real[upper_calc_index:lower_calc_index]),
                .even_input_imag(even_fft_imag[upper_calc_index:lower_calc_index]),
                .odd_input_real(odd_fft_real[upper_calc_index:lower_calc_index]),
                .odd_input_imag(odd_fft_imag[upper_calc_index:lower_calc_index]),

                .twiddle_real(twiddles_real[upper_twiddle_index:lower_twiddle_index]),
                .twiddle_imag(twiddles_imag[upper_twiddle_index:lower_twiddle_index]),

                .sum_term_real(output_real_buff[upper_calc_index:lower_calc_index]),
                .sum_term_imag(output_imag_buff[upper_calc_index:lower_calc_index]),
                .diff_term_real(output_real_buff[upper_calc_index + (buffer_size / 2):lower_calc_index + (buffer_size / 2)]),
                .diff_term_imag(output_imag_buff[upper_calc_index + (buffer_size / 2):lower_calc_index + (buffer_size / 2)])
            );
        end
    end
endgenerate

endmodule

`endif