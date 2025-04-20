module FFT_Breakdown #(
    parameter buffer_size = 32,
    sample_size = 32
)
(
    input logic signed[buffer_size * sample_size - 1:0] input_real,

    output logic signed[(buffer_size * sample_size / 2) - 1:0] output_even,
    output logic signed[(buffer_size * sample_size / 2) - 1:0] output_odd
);

genvar loop_index;

logic signed[((buffer_size * sample_size) / 2) - 1:0] even_buffer;
logic signed[((buffer_size * sample_size) / 2) - 1:0] odd_buffer;

generate
    for(loop_index = 0; loop_index < buffer_size; loop_index = loop_index + 2) begin
        assign even_buffer[((loop_index / 2) * sample_size) + sample_size - 1 : (loop_index / 2) * sample_size] = 
            input_real[(loop_index * sample_size) + sample_size - 1 : loop_index * sample_size];

        assign odd_buffer[((loop_index / 2) * sample_size) + sample_size - 1 : (loop_index / 2) * sample_size] = 
            input_real[((loop_index + 1) * sample_size) + sample_size - 1 : (loop_index + 1) * sample_size];
    end
endgenerate

assign output_even = even_buffer;
assign output_odd = odd_buffer;

endmodule