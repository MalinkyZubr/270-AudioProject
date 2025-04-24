#include <stdio.h>
#include <stdlib.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"


#define SPI_PORT    spi0
#define PIN_MISO    16
#define PIN_CS      17
#define PIN_SCK     18
#define PIN_MOSI    19
#define SPI_SPEED   1000000 

#define SAMPLE_SIZE_BYTES 4 
#define FFT_SIZE          32
#define TOTAL_BYTES       (SAMPLE_SIZE_BYTES * FFT_SIZE)

#define NUM_WINDOWS       5   

int32_t input_samples[FFT_SIZE];
int32_t fft_results[FFT_SIZE];

void spi_send_fft_data(int32_t *input, int32_t *output) {
    uint8_t tx_buf[TOTAL_BYTES] = {0};
    uint8_t rx_buf[TOTAL_BYTES] = {0};
    
    for (int i = 0; i < FFT_SIZE; i++) {
        tx_buf[i*4 + 0] = (input[i] >> 24) & 0xFF;
        tx_buf[i*4 + 1] = (input[i] >> 16) & 0xFF;
        tx_buf[i*4 + 2] = (input[i] >> 8)  & 0xFF;
        tx_buf[i*4 + 3] = (input[i])       & 0xFF;  
    }
    
    gpio_put(PIN_CS, 0);  
    
    spi_write_read_blocking(SPI_PORT, tx_buf, rx_buf, TOTAL_BYTES);
    
    gpio_put(PIN_CS, 1); 
    
    for (int i = 0; i < FFT_SIZE; i++) {
        output[i] = ((int32_t)rx_buf[i*4 + 0] << 24) | 
                    ((int32_t)rx_buf[i*4 + 1] << 16) |
                    ((int32_t)rx_buf[i*4 + 2] << 8)  |
                    ((int32_t)rx_buf[i*4 + 3]);        
    }
}

void process_binary_file(const char *filename) {
    FILE *file = fopen(filename, "rb");
    if (!file) {
        printf("Failed to open input file: %s\n", filename);
        return;
    }
    
    for (int window = 0; window < NUM_WINDOWS; window++) {
        fseek(file, window * FFT_SIZE * sizeof(int32_t), SEEK_SET);
        
        size_t read = fread(input_samples, sizeof(int32_t), FFT_SIZE, file);
        if (read != FFT_SIZE) {
            printf("Warning: Incomplete read at window %d. Got %zu samples.\n", window, read);
            for (size_t i = read; i < FFT_SIZE; i++) {
                input_samples[i] = 0;
            }
        }
        
        spi_send_fft_data(input_samples, fft_results);
        
        for (int i = 0; i < FFT_SIZE; i++) {
            printf("  Bin %02d: %d\n", i, fft_results[i]);
        }
    }
    
    fclose(file);
    return;
}

void init_spi(void) {
    spi_init(SPI_PORT, SPI_SPEED);
    
    gpio_set_function(PIN_MISO, GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);
    gpio_set_function(PIN_SCK, GPIO_FUNC_SPI);
    
    gpio_init(PIN_CS);
    gpio_set_dir(PIN_CS, GPIO_OUT);
    gpio_put(PIN_CS, 1);  
}


int main() {
    stdio_init_all();
    
    sleep_ms(2000);
    
    init_spi();
    process_binary_file("audio_samples.bin");
    
    }
    
    return 0;
}
