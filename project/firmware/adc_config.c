#include "pico/stdlib.h"
#include "hardware/adc.h"

#define SAMPLE_RATE 32000 // Hz
#define NUM_SAMPLES 32
#define ADC_PIN 26

uint16_t audio_samples[NUM_SAMPLES];

void adc_setup() {
    adc_init();
    adc_gpio_init(ADC_PIN);
    adc_select_input(0); // ADC0
}

void sample_audio() {
    uint32_t interval = 1000000 / SAMPLE_RATE; // microseconds
    
    for (int i = 0; i < NUM_SAMPLES; i++) {
        audio_samples[i] = adc_read();
        sleep_us(interval);
    }
}
