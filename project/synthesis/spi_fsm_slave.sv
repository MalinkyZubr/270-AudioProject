module SPI_FFT_Interface #(
    parameter sample_size = 32,
    parameter buffer_size = 32,
    parameter byte_size = 8    
)(
    input  logic clk,          
    input  logic rst,          

    input  logic spi_clk, 
    input  logic spi_cs,  
    input  logic spi_mosi,
    output logic spi_miso,
    
    output logic start_fft,   
    input  logic fft_done,    
    output logic [sample_size-1:0] input_samples [buffer_size-1:0], 
    input  logic [sample_size-1:0] fft_results [buffer_size-1:0]    
);
    localparam total_bytes = (sample_size / byte_size) * buffer_size; 
    
    // State machine definition
    typedef enum logic [2:0] {
        IDLE,
        RECEIVING,
        START_PROCESSING,
        PROCESSING,
        SENDING
    } state_t;
    
    state_t state;
    logic [7:0] byte_cnt;         
    logic [7:0] rx_byte;                           
    logic [7:0] tx_byte;                           
    logic [2:0] bit_cnt;                           
    logic [7:0] rx_buffer [total_bytes-1:0];       
    logic [7:0] tx_buffer [total_bytes-1:0];       
    
    always_ff @(posedge spi_clk or posedge rst) begin
        if (rst) begin
            bit_cnt <= 0;
            rx_byte <= 0;
        end 
        else if (!spi_cs) begin
            rx_byte <= {rx_byte[6:0], spi_mosi};
            
            if (bit_cnt == 7)
                bit_cnt <= 0;
            else
                bit_cnt <= bit_cnt + 1;
        end
    end
    
    always_ff @(negedge spi_clk or posedge rst) begin
        if (rst) 
            spi_miso <= 0;
        else if (!spi_cs)
            spi_miso <= tx_byte[7-bit_cnt]; 
        else
            spi_miso <= 0;
    end
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            byte_cnt <= 0;
            start_fft <= 0;
            
            for (int i = 0; i < total_bytes; i++) begin
                rx_buffer[i] <= 0;
                tx_buffer[i] <= 0;
            end
            
            for (int i = 0; i < buffer_size; i++)
                input_samples[i] <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    byte_cnt <= 0;
                    start_fft <= 0;
                    
                    if (!spi_cs)
                        state <= RECEIVING;
                end
                
                RECEIVING: begin
                    if (spi_cs) begin
                        state <= IDLE;
                    end
                    else if (bit_cnt == 0) begin 
                        rx_buffer[byte_cnt] <= rx_byte;
                        
                        if (byte_cnt == total_bytes - 1) begin
                            state <= START_PROCESSING;
                            
                            for (int i = 0; i < buffer_size; i++) begin
                                for (int j = 0; j < sample_size/byte_size; j++) begin
                                    input_samples[i][j*byte_size +: byte_size] <= 
                                        rx_buffer[i*(sample_size/byte_size) + (sample_size/byte_size-1-j)];
                                end
                            end
                        end
                        else begin
                            byte_cnt <= byte_cnt + 1;
                        end
                    end
                end
                
                START_PROCESSING: begin
                    start_fft <= 1;
                    state <= PROCESSING;
                end
                
                PROCESSING: begin
                    start_fft <= 0;
                    
                    if (fft_done) begin
                        for (int i = 0; i < buffer_size; i++) begin
                            for (int j = 0; j < sample_size/byte_size; j++) begin
                                tx_buffer[i*(sample_size/byte_size) + j] <= 
                                    fft_results[i][(sample_size/byte_size-1-j)*byte_size +: byte_size];
                            end
                        end
                        
                        byte_cnt <= 0;
                        state <= SENDING;
                    end
                end
                
                SENDING: begin
                    if (spi_cs) begin
                        state <= IDLE;
                    end
                    else if (bit_cnt == 0) begin
                        tx_byte <= tx_buffer[byte_cnt];
                        
                        if (byte_cnt == total_bytes - 1)
                            state <= IDLE;
                        else
                            byte_cnt <= byte_cnt + 1;
                    end
                end
            endcase
        end
    end
    
endmodule
