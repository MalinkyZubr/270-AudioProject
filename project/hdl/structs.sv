`default_nettype none


// MUST CONVERT ALL TO BE SIGNED
typedef logic reg [15:0] SPI_Input_Buffer [0:31]; // input should be an array of the 16 bit integers read by the pico ADC, to be mapped to 8 bit values
typedef logic reg [7:0] Mapped_Buffer [0:31]; // register to store 32 points of 16-8 mapped data
typedef logic reg [15:0] Complex_Integer; // register to store an 8 bit complex number (integer)

typedef enum {IDLE, COMPUTING, DONE} FFT_Unit_State;

module Map_Bit_Space #(parameter from = 16, to = 8) // MAKE SURE from > to
( // transformation from the 16 bit onto 8 bit space
    input logic[from - 1:0] input_value,
    output logic[to - 1:0] output_value
);

logic[from - 1:0] calculation_buffer;

assign calculation_buffer = ((((1 << to) - 1) * input_value) / ((1 << from) - 1));
assign output_value = calculation_buffer; // truncation is okay, since value is mapped to 8 bits

endmodule


// module Complex_Magnitude(
//     input Complex_Integer complex,
//     input logic clock,

//     output logic[7:0] magnitude
// );

// logic[15:0] calculation_buffer[1:0];
// logic[16:0] addition_buffer;

// assign calculation_buffer[0] = complex[7:0] ** 2; // load the square of the real part into the first buffer
// assign calculation_buffer[1] = complex[15:8] ** 2; // load the square of the imaginary part into the second buffer
// assign addition_buffer = calculation_buffer[1] + calculation_buffer[0]; // load the sum of the previous 2 calculations into the first buffer
// // maximum value for either caluclation buffer is 65025. Max sum will be 130050. Need 17 bits for max value 131071
// // must have a way to calculate the square root in here safely

// assign calculation_buffer[] = complex[7:0] ** 2;

// endmodule

// `default_nettype none
// module Square_Root( // approximation of the square root. With 8 bit integers, perfect accuracy is already a secondary concern!
//     input logic[16:0] radicand,
//     input logic en,
//     input logic clock,
//     input logic load,
//     output logic[8:0] root, // maximum value is about 360. use 9 bits to be safe, truncate later
//     output logic done_flag
// );

// logic [16:0] next_value;
// logic [16:0] current_value;

// always_ff @(posedge clock or posedge load) begin
//     if(en) begin
//         if(load) begin
//             current_value <= radicand;
//             done_flag <= 0;

//             if(radicand == 0) begin
//                 root <= 1'b0;
//                 done_flag <= 1'b1;
//             end
//         end
//         else begin
//             current_value <= next_value;
//         end
        
//         if(next_value - current_value <= 1) begin
//             root <= current_value;
//             done_flag <= 1'b1;
//         end
//     end
// end

// always_comb begin
//     next_value = (current_value + (root / current_value)) / 2;
// end

// endmodule;