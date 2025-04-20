#include "pico/stdlib.h"
#include "hardware/spi.h"

// SPI pins
#define SPI_SCK  2
#define SPI_MOSI 3
#define SPI_CS   5

void spi_setup() {
    spi_init(spi0, 1000000);  // 1 MHz
    
    gpio_set_function(SPI_SCK, GPIO_FUNC_SPI);
    gpio_set_function(SPI_MOSI, GPIO_FUNC_SPI);
    
    gpio_init(SPI_CS);
    gpio_set_dir(SPI_CS, GPIO_OUT);
    gpio_put(SPI_CS, 1);
}

void send_samples_to_fft(uint16_t *samples) {
    gpio_put(SPI_CS, 0);
    
    for (int i = 0; i < 32; i++) {
        uint32_t value = ((uint32_t)samples[i]) << 20;
        
        uint8_t bytes[4];
        bytes[0] = (value >> 24) & 0xFF;
        bytes[1] = (value >> 16) & 0xFF;
        bytes[2] = (value >> 8) & 0xFF;
        bytes[3] = value & 0xFF;
        
        spi_write_blocking(spi0, bytes, 4);
    }
    
    gpio_put(SPI_CS, 1);
}
