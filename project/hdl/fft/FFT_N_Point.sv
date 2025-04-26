`default_nettype none


// should convert all registers to signed for FFT, considering signed twiddles

module FFT_N_Point #(
    parameter twiddle_size = 16, 
    buffer_size = 32,
    sample_size = 32,
    no_float_mult = 1000
)
( // this is the base case
    input logic signed[buffer_size * sample_size - 1:0] input_real,

    output logic signed[buffer_size * sample_size - 1:0] output_real,
    output logic signed[buffer_size * sample_size - 1:0] output_imag
);
 // standardize for multi radix later
genvar loop_index;

logic signed[((buffer_size * sample_size) / 2) - 1:0] even_buffer;
logic signed[((buffer_size * sample_size) / 2) - 1:0] odd_buffer;

FFT_Breakdown #(.buffer_size(buffer_size), .sample_size(sample_size)) fft_breakdown_unit (
    .input_real(input_real),
    .output_even(even_buffer),
    .output_odd(odd_buffer)
);

generate
    logic signed[(twiddle_size * buffer_size / 2) - 1:0] twiddles_real;
    logic signed[(twiddle_size * buffer_size / 2) - 1:0] twiddles_imag;

    Twiddle_Coordinator #(.twiddle_size(twiddle_size), .buffer_size(buffer_size))
        butterfly_coordinator (
            .real_twiddles(twiddles_real),
            .imag_twiddles(twiddles_imag)
        );
        
    if(buffer_size == 2) begin
        FFT_Base_Butterfly #(.twiddle_size(twiddle_size),
            .sample_size(sample_size),
            .no_float_mult(no_float_mult)    
        ) butterfly_unit_base (
            .even_buffer(even_buffer),
            .odd_buffer(odd_buffer),
            .twiddles_real(twiddles_real),
            .twiddles_imag(twiddles_imag),
            .output_real(output_real),
            .output_imag(output_imag)
        );
    end

    else if ((buffer_size & (buffer_size - 1)) == 0 && buffer_size > 2) begin // stnadardize later for different radicies
        logic signed[((buffer_size * sample_size) / 2) - 1:0] even_fft_real;
        logic signed[((buffer_size * sample_size) / 2) - 1:0] even_fft_imag;

        logic signed[((buffer_size * sample_size) / 2) - 1:0] odd_fft_real;
        logic signed[((buffer_size * sample_size) / 2) - 1:0] odd_fft_imag;

        FFT_N_Point #(.buffer_size(buffer_size / 2), 
            .twiddle_size(twiddle_size), 
            .sample_size(sample_size),
            .no_float_mult(no_float_mult))
            inst_even_child (
                .input_real(even_buffer),
                .output_real(even_fft_real),
                .output_imag(even_fft_imag)
            );

        FFT_N_Point #(.buffer_size(buffer_size / 2), 
            .twiddle_size(twiddle_size), 
            .sample_size(sample_size),
            .no_float_mult(no_float_mult))
            inst_odd_child (
                .input_real(odd_buffer),
                .output_real(odd_fft_real),
                .output_imag(odd_fft_imag)
            );
        
        FFT_Butterfly #(.twiddle_size(twiddle_size), 
            .buffer_size(buffer_size), 
            .sample_size(sample_size), 
            .no_float_mult(no_float_mult)
        ) butterfly_unit(
            .even_fft_real(even_fft_real),
            .even_fft_imag(even_fft_imag),
            .odd_fft_real(odd_fft_real),
            .odd_fft_imag(odd_fft_imag),
            .twiddles_real(twiddles_real),
            .twiddles_imag(twiddles_imag),
            .output_real(output_real),
            .output_imag(output_imag)
        );
    end
endgenerate

endmodule
