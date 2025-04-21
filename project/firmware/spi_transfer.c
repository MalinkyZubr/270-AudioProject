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
        uint16_t value = samples[i];  // 16-bit sample
        
        uint8_t bytes[2];  // 2 bytes for 16-bit data
        bytes[0] = (value >> 8) & 0xFF;  // High byte
        bytes[1] = value & 0xFF;         // Low byte
        
        spi_write_blocking(spi0, bytes, 2);  // Send 2 bytes instead of 4
    }
    
    gpio_put(SPI_CS, 1);
}
