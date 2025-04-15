`default_nettype none


module Map_Bit_Space #(parameter from = 16, to = 8) // MAKE SURE from > to
( // transformation from the 16 bit onto 8 bit space
    input logic[from - 1:0] input_value,
    output logic[to - 1:0] output_value
);

logic[from - 1:0] calculation_buffer;

assign calculation_buffer = ((((1 << to) - 1) * input_value) / ((1 << from) - 1));
assign output_value = calculation_buffer; // truncation is okay, since value is mapped to 8 bits

endmodule