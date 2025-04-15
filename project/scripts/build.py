from gen_twiddle import generate_twiddles_file
import os
import json


def load_config() -> dict:
    with open(f"{os.path.dirname(os.path.abspath(__file__))}/gen_conf.json", "r") as f:
        config = f.read()
        config_dict = json.loads(config)

    return config_dict

def configure_twiddles(config: dict) -> None:
    twiddle_config = config["twiddle_generation"]
    twiddle_file = generate_twiddles_file(twiddle_config["buffsize"], twiddle_config["multiplier"])

    with open(twiddle_config["twiddle_file_abspath"], "w") as f:
        f.write(twiddle_file)

def build_codebase():
    pass


if __name__ == "__main__":
    config = load_config()
    configure_twiddles(config)