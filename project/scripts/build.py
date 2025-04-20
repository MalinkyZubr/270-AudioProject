from gen_twiddle import generate_twiddles_file
import os
import json


def load_config() -> dict:
    with open(f"{os.path.dirname(os.path.abspath(__file__))}/gen_conf.json", "r") as f:
        config = f.read()
        config_dict = json.loads(config)

    return config_dict

def configure_twiddles(config: dict, buffsize) -> None:
    twiddle_config = config["twiddle_generation"]
    twiddle_file = generate_twiddles_file(buffsize, twiddle_config["multiplier"])

    with open(twiddle_config["twiddle_file_abspath"] + twiddle_config["twiddle_name_prefix"] + str(buffsize) +".sv", "w") as f:
        f.write(twiddle_file)

def build_codebase():
    pass


if __name__ == "__main__":
    config = load_config()

    buffsize = config["twiddle_generation"]["buffsize"]

    while buffsize >= 2:
        configure_twiddles(config, buffsize)
        buffsize //= 2