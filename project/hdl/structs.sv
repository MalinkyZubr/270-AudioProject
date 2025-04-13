`default_nettype none


typedef enum {
    READING, 
    COMPUTING, 
    DONE,
} FFT_Unit_State;

module Map_Bit_Space #(parameter from = 16, to = 8) // MAKE SURE from > to
( // transformation from the 16 bit onto 8 bit space
    input logic[from - 1:0] input_value,
    output logic[to - 1:0] output_value
);

logic[from - 1:0] calculation_buffer;

assign calculation_buffer = ((((1 << to) - 1) * input_value) / ((1 << from) - 1));
assign output_value = calculation_buffer; // truncation is okay, since value is mapped to 8 bits

endmodule

module Adder #(parameter data_size)
(
    input logic signed[data_size - 1:0] first_term,
    input logic signed[data_size - 1:0] second_term,
    output logic signed[data_size - 1:0] result
);

assign result = first_term + second_term;

endmodule

module Subtractor #(parameter data_size)
(
    input logic signed[data_size - 1:0] first_term,
    input logic signed[data_size - 1:0] second_term,
    output logic signed[data_size - 1:0] result
);

assign result = first_term - second_term;

endmodule

module Multiplier #(parameter data_size)
(
    input logic signed[data_size - 1:0] first_term,
    input logic signed[data_size - 1:0] second_term,
    output logic signed[data_size - 1:0] result
);

assign result = first_term * second_term;

endmodule

module Overwrite_Data_Buffer #(parameter num_elements = 32, elem_size = 8)
(
    input logic overwrite,
    input logic clock,
    input logic signed[(num_elements * elem_size - 1):0] read_buffer,
    output logic signed[(num_elements * elem_size - 1):0] write_buffer,
);

always_ff @( posedge clock ) begin
    if(overwrite) begin
        write_buffer <= read_buffer;
    end
end
endmodule

module Data_Buffer_Write_Index #(parameter num_elements = 32, elem_size = 8, index_size = 5)
    (
        input logic clock,
        input logic write,
        input logic[index_size - 1:0] index,
        output logic signed[(num_elements * elem_size - 1):0] full_buffer,
        input logic signed[elem_size - 1:0] write_buffer
    );

    logic write_index;
    assign write_index = index * elem_size;

    always_ff @( posedge clock ) begin
        if(write) begin
            full_buffer[write_index + elem_size - 1:write_index] <= write_buffer;
        end
    end
endmodule

module Data_Buffer_Read_Index #(parameter num_elements = 32, elem_size = 8, index_size = 5)
    (
        input logic clock,
        input logic read,
        input logic[index_size - 1:0] index,
        input logic signed[(num_elements * elem_size - 1):0] full_buffer,
        output logic signed[elem_size - 1:0] read_buffer
    );
    logic read_index;
    assign read_index = index * elem_size;

    always_ff @( posedge clock ) begin
        if(write) begin
            read_buffer <= full_buffer[write_index + elem_size - 1:write_index];
        end
    end
endmodule
