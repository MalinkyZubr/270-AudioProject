iverilog -g2012 -o ./twiddle ../../hdl/fft/twiddle.sv ./twiddle_test.sv
vvp ./twiddle
