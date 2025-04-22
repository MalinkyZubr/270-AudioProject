import os
import numpy as np
import matplotlib.pyplot as plt


filepath = os.path.dirname(os.path.abspath(__file__))


def run_fft_n_point():
    with open(filepath + "/n_calc_results", "r") as f:
        content = f.read()

    listed_data = content.split("\n")

    complex_list = []

    for complex_value in listed_data:
        bifurcated_string = complex_value.split(",")

        if(len(bifurcated_string) > 1):
            complex_list.append(complex(int(bifurcated_string[0]), int(bifurcated_string[1])))

    return complex_list

def generate_test_fft(bin_size):
    j = np.asarray([x for x in range(bin_size)])
    sined = 128 * (10 * np.sin(j * 15000) + 20 * np.cos(j * 4000) + 10 * np.cos(j * 5000) + np.cos(j * 18000) + np.cos(j * 400))

    fft = list(np.fft.fft(sined))

    return fft

def plot_fft(complex_list: list):
    mags = [abs(value) / 1000 for value in complex_list]

    plt.plot(mags)


if __name__ == "__main__":
    complexes = run_fft_n_point()
    plot_fft(complexes)
    plot_fft(generate_test_fft(16))

    plt.legend(["Experimental", "Ideal"])

    plt.show()


