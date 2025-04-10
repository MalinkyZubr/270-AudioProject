`default_nettype none
`include "../structs.sv"

// should convert all registers to signed for FFT, considering signed twiddles

module FFT_2_Point( // this is the base case
    input Complex_Integer even_input,
    input Complex_Integer odd_output,

    output Complex_Integer p,
    output Complex_Integer q
);

always_comb begin

end

endmodule