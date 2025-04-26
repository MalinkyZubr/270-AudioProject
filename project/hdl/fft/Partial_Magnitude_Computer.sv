`default_nettype none



module Partial_Magnitude_Computer #(
    parameter sample_size = 32,
    buffer_size = 32
)
(
    input logic signed[buffer_size * sample_size - 1:0] input_real,
    input logic signed[buffer_size * sample_size - 1:0] input_imag,

    output logic signed[buffer_size * sample_size - 1:0] output_mags
);

    genvar loop_index;

    generate
        for (loop_index = 0; loop_index < buffer_size; loop_index++) begin
            localparam int upper_calc_index = (sample_size * loop_index) + sample_size - 1;
            localparam int lower_calc_index = sample_size * loop_index;

            assign output_mags[upper_calc_index:lower_calc_index] = 
                (input_real[upper_calc_index:lower_calc_index] * input_real[upper_calc_index:lower_calc_index]) +
                (input_imag[upper_calc_index:lower_calc_index] * input_imag[upper_calc_index:lower_calc_index]);
        end
    endgenerate

endmodule
