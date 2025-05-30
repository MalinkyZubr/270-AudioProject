# cd ../../hdl/fft
iverilog -g2012 -o ./bin/fft_calc ./fft_calc_test.sv ../../hdl/fft/*.sv ../../hdl/fft/twiddle/*.sv &> ./logs/calc_log.log
iverilog -g2012 -I ../../hdl/fft -o ./bin/fft ./fft_test.sv ../../hdl/fft/*.sv ../../hdl/fft/twiddle/*.sv &> ./logs/fft_log.log
iverilog -g2012 -o ./bin/fft_mag_calc ./fft_mag_test.sv ../../hdl/fft/*.sv ../../hdl/fft/twiddle/*.sv &> ./logs/mag_log.log
iverilog -g2012 -o ./bin/fft_n_calc ./fft_n_point_test.sv ../../hdl/fft/*.sv ../../hdl/fft/twiddle/*.sv &> ./logs/n_point_log.log
iverilog -g2012 -o ./bin/fft_breakdown ./fft_breakdown_test.sv ../../hdl/fft/*.sv ../../hdl/fft/twiddle/*.sv &> ./logs/breakdown.log
iverilog -g2012 -o ./bin/butterfly ./butterfly_unit_test.sv ../../hdl/fft/*.sv ../../hdl/fft/twiddle/*.sv &> ./logs/buttefly.log

vvp ./bin/fft_calc
vvp ./bin/fft
vvp ./bin/fft_mag_calc
vvp ./bin/fft_n_calc > ./n_calc_results
vvp ./bin/fft_breakdown
vvp ./bin/butterfly