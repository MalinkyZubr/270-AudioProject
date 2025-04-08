`default_nettype none


typedef logic reg [15:0] SPI_Input_Buffer [0:31]; // input should be an array of the 16 bit integers read by the pico ADC, to be mapped to 8 bit values
typedef logic reg [7:0] Mapped_Buffer [0:31]; // register to store 32 points of 16-8 mapped data
typedef logic reg [15:0] Complex_Integer; // register to store an 8 bit complex number (integer)


module Map_16_8( // transformation from the 16 bit onto 8 bit space
    input logic[15:0] input,
    output logic[7:0] output
);

logic[15:0] calculation_buffer;

assign calculation_buffer = 255 * input / 65535
assign output = calculation_buffer; // truncation is okay, since value is mapped to 8 bits

endmodule

module Complex_Magnitude(
    input Complex_Integer complex,
    output logic[7:0] magnitude
);

logic[15:0] calculation_buffer[1:0];

assign calculation_buffer[0] = complex[7:0] ** 2; // load the square of the real part into the first buffer
assign calculation_buffer[1] = complex[15:8] ** 2; // load the square of the imaginary part into the second buffer
assign calculation_buffer[0] = calculation_buffer[1] + calculation_buffer[0]; // load the sum of the previous 2 calculations into the first buffer


assign calculation_buffer[] = complex[7:0] ** 2

endmodule

module Square_Root( // approximation of the square root. With 8 bit integers, perfect accuracy is already a secondary concern!

);

endmodule;
