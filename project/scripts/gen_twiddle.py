# program to precompute twiddle factor up to specific accuracy
import numpy as np
import jinja2
import os


def compute_twiddle_factors(buffsize: int, multiplier: int) -> list[tuple[int, int]]: # index corresponds to index in the fft buffer
    twiddles = []

    for index in range(buffsize // 2):
        real_twiddle = np.cos(-2 * np.pi * index / buffsize)
        if np.abs(real_twiddle) < (1 / multiplier):
            real_twiddle = 0

        imaginary_twiddle = np.sin(-2 * np.pi * index / buffsize)
        if np.abs(imaginary_twiddle) < (1 / multiplier):
            imaginary_twiddle = 0

        twiddles.append((int(np.ceil(real_twiddle * multiplier)), int(np.ceil(imaginary_twiddle * multiplier))))
        #print(twiddles[index])
    return twiddles

def get_bits(max_value, roundup: bool=True) -> int:
    min_bits = int(np.ceil(np.log2(max_value)) + 1) # plus 1 to account for signed
    if roundup:
        return 1 << (int(np.log2(min_bits)) + 1)

    return min_bits

def compute_bits_necessary(twiddles: list[tuple[int, int]]) -> int:
    real_values_max = max([x[0] for x in twiddles])
    imag_values_max = max([x[1] for x in twiddles])

    bits = get_bits(max([real_values_max, imag_values_max])) # plus 1 to account for signed

    return bits

def convert_binary(twiddle: int, twiddle_size: int) -> str:
    # if twiddle < 0:
    #     twiddle = ~twiddle + 1
    mask = (1 << twiddle_size) - 1
    return f"{twiddle_size}'b{format(twiddle & mask, f'0{twiddle_size + 1}b')[1:]}"

def format_twiddles(twiddles: list[tuple[int, int]], twiddle_size: int) -> tuple[str, str]:
    real_twiddle_array: str = ""
    imag_twiddle_array: str = ""

    for index, value in enumerate(twiddles):
        real, imag = value
        real_twiddle_array += f"assign real_twiddles[{index * twiddle_size + twiddle_size - 1}:{index * twiddle_size}] = " + convert_binary(real, twiddle_size) + ";\n"
        imag_twiddle_array += f"assign imag_twiddles[{index * twiddle_size + twiddle_size - 1}:{index * twiddle_size}] = " + convert_binary(imag, twiddle_size) + ";\n"
    
    return real_twiddle_array, imag_twiddle_array

def input_handling() -> tuple[int, int]:
    buffersize = int(input("Enter a 2's power buffersize: "))
    if((buffersize - 1 & buffersize) != 0 or buffersize < 2):
        raise IOError("Buffersize must be 2's power and greater than or equal to 2")
    
    accuracy_multiplier = int(input("Enter a multiplier (preferebly power of 10): "))

    return buffersize, accuracy_multiplier

def generate_twiddles_file(buffsize, multiplier):
    with open(f"{os.path.dirname(os.path.abspath(__file__))}/templates/twiddle_template.sv", "r") as f:
        template = f.read()

    environment = jinja2.Environment()
    template_obj = environment.from_string(template)

    twiddles = compute_twiddle_factors(buffsize, multiplier)
    bits_per_twiddle = compute_bits_necessary(twiddles)
    real, imag = format_twiddles(twiddles, bits_per_twiddle)


    out = template_obj.render(
        twiddle_size=bits_per_twiddle, 
        num_twiddles=buffsize // 2, 
        real_twiddles=real,
        imag_twiddles=imag,
        suffix = buffsize
    )

    return out, bits_per_twiddle

def generate_coordinator_lut(buffsize: int):
    suffix = 2
    lut_string = ""

    while suffix <= buffsize:
        lut_string += f"\t\t{suffix} : Twiddle_Storage_{suffix} twiddler (.real_twiddles(real_twiddles), .imag_twiddles(imag_twiddles));\n"
        suffix *= 2

    return lut_string

def generate_coordinator_file(buffsize: int, bits_per_twiddle: int):
    with open(f"{os.path.dirname(os.path.abspath(__file__))}/templates/twiddle_coordinator_template.sv", "r") as f:
        template = f.read()

    environment = jinja2.Environment()
    template_obj = environment.from_string(template)

    lut = generate_coordinator_lut(buffsize)

    out = template_obj.render(
        twiddle_lut=lut,
        twiddle_size=bits_per_twiddle
    )

    return out