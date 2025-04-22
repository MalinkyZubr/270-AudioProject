/**
 * SPI Master Module for Raspberry Pi Pico
 * Captures audio via ADC, sends to FPGA for FFT processing
 * Receives FFT results back for LED matrix display
 */
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/spi.h"
#include "hardware/dma.h"
#include "hardware/adc.h"
#include "hardware/clocks.h"

// Define SPI pins
#define SPI_PORT spi0
#define PIN_MISO 16
#define PIN_CS   17
#define PIN_SCK  18
#define PIN_MOSI 19

// Buffer sizes
#define NUM_SAMPLES 32
#define SAMPLE_SIZE_BITS 32
#define SAMPLE_SIZE_BYTES (SAMPLE_SIZE_BITS / 8)
#define BUFFER_SIZE (NUM_SAMPLES * SAMPLE_SIZE_BYTES)

// ADC settings
#define ADC_CHANNEL 0  // ADC0 on GPIO26
#define ADC_SAMPLE_RATE 8000 // 8kHz sampling

// Buffers for transmit and receive
uint8_t tx_buffer[BUFFER_SIZE];
uint8_t rx_buffer[BUFFER_SIZE];

// DMA channels
int dma_tx, dma_rx;

void spi_master_init() {
    // Initialize SPI with default settings
    spi_init(SPI_PORT, 1000000);  // 1MHz clock speed
    
    // Set SPI format
    spi_set_format(SPI_PORT, 8, SPI_CPOL_0, SPI_CPHA_0, SPI_MSB_FIRST);
    
    // Configure GPIOs
    gpio_set_function(PIN_MISO, GPIO_FUNC_SPI);
    gpio_set_function(PIN_CS, GPIO_FUNC_SIO);
    gpio_set_function(PIN_SCK, GPIO_FUNC_SPI);
    gpio_set_function(PIN_MOSI, GPIO_FUNC_SPI);
    
    // Chip select as output and set high (inactive)
    gpio_set_dir(PIN_CS, GPIO_OUT);
    gpio_put(PIN_CS, 1);
    
    // Initialize DMA channels
    dma_tx = dma_claim_unused_channel(true);
    dma_rx = dma_claim_unused_channel(true);
    
    printf("SPI Master initialized\n");
}

void adc_init_audio() {
    // Initialize ADC for audio sampling
    adc_init();
    adc_gpio_init(26 + ADC_CHANNEL); // GPIO 26 is ADC0
    adc_select_input(ADC_CHANNEL);
    
    // Calculate clock divider for desired sample rate
    float clock_div = clock_get_hz(clk_adc) / (ADC_SAMPLE_RATE * 96.0);
    adc_set_clkdiv(clock_div);
    
    printf("ADC initialized for audio sampling at %d Hz\n", ADC_SAMPLE_RATE);
}

void capture_audio_samples(uint32_t *audio_samples) {
    printf("Capturing %d audio samples...\n", NUM_SAMPLES);
    
    for (int i = 0; i < NUM_SAMPLES; i++) {
        // Start ADC conversion
        adc_select_input(ADC_CHANNEL);
        adc_run(true);
        
        // Wait for conversion to complete
        while (adc_fifo_is_empty()) {
            tight_loop_contents();
        }
        
        // Read 12-bit sample from ADC
        uint16_t raw_sample = adc_fifo_get();
        adc_run(false);
        
        // Convert to signed 32-bit and center around zero
        // ADC gives 0-4095, we convert to -2048 to 2047
        int32_t centered_sample = ((int32_t)raw_sample) - 2048;
        
        // Scale up to use more of the 32-bit range
        // Shift left by 16 bits to use upper bits of 32-bit word
        audio_samples[i] = (uint32_t)(centered_sample << 16);
        
        // Delay to maintain sample rate
        busy_wait_us(1000000 / ADC_SAMPLE_RATE);
    }
    
    printf("Audio capture complete\n");
}

void spi_master_send_receive(const uint32_t *audio_samples, uint32_t *fft_results) {
    // Prepare the transmit buffer with audio samples
    for (int i = 0; i < NUM_SAMPLES; i++) {
        // Convert 32-bit sample to bytes in tx_buffer (MSB first)
        tx_buffer[i*4]   = (audio_samples[i] >> 24) & 0xFF;
        tx_buffer[i*4+1] = (audio_samples[i] >> 16) & 0xFF;
        tx_buffer[i*4+2] = (audio_samples[i] >> 8) & 0xFF;
        tx_buffer[i*4+3] = audio_samples[i] & 0xFF;
    }
    
    // Configure DMA channels
    // DMA channel for TX
    dma_channel_config tx_config = dma_channel_get_default_config(dma_tx);
    channel_config_set_transfer_data_size(&tx_config, DMA_SIZE_8);
    channel_config_set_dreq(&tx_config, spi_get_dreq(SPI_PORT, true));
    
    // DMA channel for RX
    dma_channel_config rx_config = dma_channel_get_default_config(dma_rx);
    channel_config_set_transfer_data_size(&rx_config, DMA_SIZE_8);
    channel_config_set_dreq(&rx_config, spi_get_dreq(SPI_PORT, false));
    channel_config_set_read_increment(&rx_config, false);
    channel_config_set_write_increment(&rx_config, true);
    
    // Start DMA transfers
    dma_channel_configure(dma_tx, &tx_config,
                          &spi_get_hw(SPI_PORT)->dr,  // Write to SPI data register
                          tx_buffer,                 // Read from tx_buffer
                          BUFFER_SIZE,               // Transfer BUFFER_SIZE bytes
                          false);                    // Don't start yet
    
    dma_channel_configure(dma_rx, &rx_config,
                          rx_buffer,                 // Write to rx_buffer
                          &spi_get_hw(SPI_PORT)->dr,  // Read from SPI data register
                          BUFFER_SIZE,               // Transfer BUFFER_SIZE bytes
                          false);                    // Don't start yet
    
    // Chip select active (low)
    gpio_put(PIN_CS, 0);
    
    // Start both DMA channels
    dma_start_channel_mask((1u << dma_tx) | (1u << dma_rx));
    
    // Wait for transfers to complete
    dma_channel_wait_for_finish_blocking(dma_tx);
    dma_channel_wait_for_finish_blocking(dma_rx);
    
    // Chip select inactive (high)
    gpio_put(PIN_CS, 1);
    
    // Process the received data - convert bytes back to 32-bit values
    for (int i = 0; i < NUM_SAMPLES; i++) {
        fft_results[i] = (rx_buffer[i*4] << 24) | 
                         (rx_buffer[i*4+1] << 16) | 
                         (rx_buffer[i*4+2] << 8) | 
                         rx_buffer[i*4+3];
    }
}

// Example function to update LED matrix with FFT results
void update_led_matrix(const uint32_t *fft_results) {
    // Implementation depends on your LED matrix interface
    // This is a placeholder for your actual LED matrix code
    printf("Updating LED matrix with FFT results\n");
    for (int i = 0; i < NUM_SAMPLES; i++) {
        printf("FFT[%d] = 0x%08x\n", i, fft_results[i]);
    }
}

int main() {
    stdio_init_all();
    spi_master_init();
    adc_init_audio();
    
    uint32_t audio_samples[NUM_SAMPLES];
    uint32_t fft_results[NUM_SAMPLES];
    
    while (1) {
        // Capture audio samples
        capture_audio_samples(audio_samples);
        
        // Send samples to FPGA and receive FFT results
        spi_master_send_receive(audio_samples, fft_results);
        
        // Update LED matrix with FFT results
        update_led_matrix(fft_results);
        
        // Wait before next capture
        sleep_ms(100);
    }
    
    return 0;
}
