from gen_twiddle import generate_twiddles_file, generate_coordinator_file
import os
import json


def load_config() -> dict:
    with open(f"{os.path.dirname(os.path.abspath(__file__))}/gen_conf.json", "r") as f:
        config = f.read()
        config_dict = json.loads(config)

    return config_dict

def configure_twiddles(config: dict, buffsize) -> None:
    twiddle_config = config["twiddle_generation"]
    twiddle_file, bits_per_twiddle = generate_twiddles_file(buffsize, twiddle_config["multiplier"])

    with open(twiddle_config["twiddle_file_abspath"] + twiddle_config["twiddle_name_prefix"] + str(buffsize) +".sv", "w") as f:
        f.write(twiddle_file)

    return bits_per_twiddle

def write_all_twiddle_files(config: dict):
    buffsize = config["twiddle_generation"]["buffsize"]
    bits_per_twiddle = 0

    while buffsize >= 2:
        bits_per_twiddle = configure_twiddles(config, buffsize)
        buffsize //= 2

    return bits_per_twiddle

def write_coordinator_file(twiddle_config: dict, bits_per_twiddle):
    filled_template = generate_coordinator_file(twiddle_config["buffsize"], bits_per_twiddle)
    with open(twiddle_config["twiddle_file_abspath"] + twiddle_config["coordinator_filename"], "w") as f:
        f.write(filled_template)

def build_codebase():
    pass


if __name__ == "__main__":
    config = load_config()
    bits_per_twiddle = write_all_twiddle_files(config)
    write_coordinator_file(config["twiddle_generation"], bits_per_twiddle)

