`default_nettype none   


module Processing_Top #(parameter buff_size, input_sample_size, output_sample_size) // buffsize also determines the size of the 
(
    input clock,
    input logic signed[(buff_size * sample_size - 1):0] input_buffer,
    input output signed[(buff_size * sample_size - 1):0] read_buffer,

    output logic done,
    input logic reset,
);

logic signed[(buff_size * sample_size - 1):0] internal_read_buffer;
logic signed[(buff_size * sample_size - 1):0] internal_write_buffer;

endmodule