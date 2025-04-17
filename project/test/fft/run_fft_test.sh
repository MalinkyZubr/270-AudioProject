
iverilog -g2012 -I ../../hdl/fft -o ./fft ../../hdl/fft/*.sv ./fft_test.sv
vvp ./fft
