#include "pico/stdlib.h"
#include "hardware/spi.h"

#define SPI_SCK  2
#define SPI_MOSI 3
#define SPI_MISO 4
#define SPI_CS   5

void spi_setup() {
    spi_init(spi0, 1000000);  // 1 MHz
    gpio_set_function(SPI_SCK, GPIO_FUNC_SPI);
    gpio_set_function(SPI_MOSI, GPIO_FUNC_SPI);
    gpio_set_function(SPI_MISO, GPIO_FUNC_SPI);
    
    gpio_init(SPI_CS);
    gpio_set_dir(SPI_CS, GPIO_OUT);
    gpio_put(SPI_CS, 1);
}

void send_samples_to_fpga(uint16_t *samples) {
    gpio_put(SPI_CS, 0);
    for (int i = 0; i < 32; i++) {
        uint8_t bytes[2] = {
            (samples[i] >> 8) & 0xFF,
            samples[i] & 0xFF
        };
        spi_write_blocking(spi0, bytes, 2);
    }
    gpio_put(SPI_CS, 1);
}

void receive_fft_from_fpga(uint32_t *bins) {
    gpio_put(SPI_CS, 0);
    for (int i = 0; i < 32; i++) {
        uint8_t raw[4] = {0, 0, 0, 0};
        spi_read_blocking(spi0, 0x00, raw, 4);
        bins[i] = (raw[0] << 24) | (raw[1] << 16) | (raw[2] << 8) | raw[3];
    }
    gpio_put(SPI_CS, 1);
}
