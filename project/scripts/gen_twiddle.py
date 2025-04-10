# program to precompute twiddle factor up to specific accuracy
import numpy as np
import jinja2
import os


def compute_twiddle_factors(buffsize: int, multiplier: int) -> list[tuple[int, int]]: # index corresponds to index in the fft buffer
    twiddles = []

    for index in range(buffsize):
        real_twiddle = np.cos(-2 * np.pi * index / buffsize)
        imaginary_twiddle = np.sin(-2 * np.pi * index / buffsize)
        twiddles.append((int(np.ceil(real_twiddle * multiplier)), int(np.ceil(imaginary_twiddle * 1000))))

    return twiddles

def compute_bits_necessary(twiddles: list[tuple[int, int]]) -> int:
    real_values_max = max([x[0] for x in twiddles])
    imag_values_max = max([x[1] for x in twiddles])

    min_bits = int(np.ceil(np.log2(max([real_values_max, imag_values_max]))) + 1) # plus 1 to account for signed
    practical_bits = 1 << (int(np.log2(min_bits)) + 1)

    return practical_bits

def format_twiddles(twiddles: list[tuple[int, int]], twiddle_size: int) -> tuple[str, str]:
    real_twiddle_array: str = ""
    imag_twiddle_array: str = ""

    for real, imag in twiddles:
        real_twiddle_array += f"{twiddle_size}'b{format()}"

if __name__ == "__main__":
    with open(f"{os.path.abspath(__file__)}/twiddle_template.sv") as f:
        template = f.read()

    environment = jinja2.Environment()
    template_obj = environment.from_string(template)

    #template = environment.

    print(compute_bits_necessary(compute_twiddle_factors(32, 1000)))