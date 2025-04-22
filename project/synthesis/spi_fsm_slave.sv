module SPI_FFT_Slave (
    input  logic        i_Clk,         // FPGA system clock
    input  logic        i_Rst_L,       // Active low reset
    input  logic        i_SPI_Clk,     // SPI clock from master
    input  logic        i_SPI_CS_n,    // Chip select (active low)
    input  logic        i_SPI_MOSI,    // Master out slave in
    output logic        o_SPI_MISO,    // Master in slave out
    output logic        o_New_Samples_Ready, // Indicates new samples ready for FFT
    input  logic [31:0] i_FFT_Output [31:0], // 32 bins of FFT result, 32-bit each
    input  logic        i_FFT_Valid    // Indicates FFT results are valid
);
  // State machine definition
  typedef enum logic [1:0] {
    IDLE,       // Waiting for SPI transaction
    RECEIVING,  // Receiving audio samples
    WAIT_FFT,   // Waiting for FFT processing to complete
    SENDING     // Sending FFT results back
  } state_t;
  
  // State variables
  state_t state, next_state;
  
  // Buffers and counters
  logic [7:0]  rx_byte;               // Current byte being received
  logic [31:0] sample_buf [31:0];     // Buffer for 32 samples, 32-bit each
  logic [7:0]  fft_out_bytes [127:0]; // 32 samples * 4 bytes = 128 bytes for output
  logic [6:0]  byte_count;            // Counts bytes in current transaction (0-127)
  logic [2:0]  bit_count;             // Counts bits in current byte (0-7)
  logic [31:0] rx_word;               // Assembled 32-bit word
  logic [1:0]  rx_byte_phase;         // Tracks which byte in the 32-bit word (0-3)
  
  // === State transition logic ===
  always_ff @(posedge i_Clk or negedge i_Rst_L) begin
    if (!i_Rst_L)
      state <= IDLE;
    else
      state <= next_state;
  end
  
  always_comb begin
    next_state = state;
    case (state)
      IDLE:
        if (!i_SPI_CS_n)
          next_state = RECEIVING;
      RECEIVING:
        if (byte_count == 127)  // 32 samples * 4 bytes = 128 bytes (0-127)
          next_state = WAIT_FFT;
      WAIT_FFT:
        if (i_FFT_Valid)
          next_state = SENDING;
      SENDING:
        if (byte_count == 127 && i_SPI_CS_n)  // All bytes sent and CS deasserted
          next_state = IDLE;
    endcase
    
    // Return to IDLE if CS is deasserted during transaction
    if (state != IDLE && i_SPI_CS_n && state != WAIT_FFT)
      next_state = IDLE;
  end
  
  // === SPI signal synchronization ===
  logic spi_mosi_sync1, spi_mosi_sync;
  logic spi_clk_sync1, spi_clk_sync;
  logic spi_cs_sync1, spi_cs_sync;
  logic prev_spi_clk;
  logic spi_clk_posedge;
  
  // 2-stage synchronizer to prevent metastability
  always_ff @(posedge i_Clk) begin
    spi_mosi_sync1 <= i_SPI_MOSI;
    spi_mosi_sync  <= spi_mosi_sync1;
    
    spi_clk_sync1  <= i_SPI_Clk;
    spi_clk_sync   <= spi_clk_sync1;
    
    spi_cs_sync1   <= i_SPI_CS_n;
    spi_cs_sync    <= spi_cs_sync1;
    
    prev_spi_clk   <= spi_clk_sync;
  end
  
  // Edge detection
  assign spi_clk_posedge = spi_clk_sync && !prev_spi_clk;
  
  // === SPI receive logic ===
  always_ff @(posedge i_Clk or negedge i_Rst_L) begin
    if (!i_Rst_L) begin
      bit_count <= 0;
      rx_byte <= 8'd0;
      byte_count <= 0;
      rx_byte_phase <= 0;
      rx_word <= 32'd0;
      
      // Initialize sample buffer
      for (int i = 0; i < 32; i++) begin
        sample_buf[i] <= 32'd0;
      end
    end
    else if (state == IDLE && next_state == RECEIVING) begin
      // Reset counters at start of new transaction
      bit_count <= 0;
      byte_count <= 0;
      rx_byte_phase <= 0;
      rx_byte <= 8'd0;
    end
    else if (spi_clk_posedge && state == RECEIVING) begin
      // Shift in bit from MOSI
      rx_byte <= {rx_byte[6:0], spi_mosi_sync};
      bit_count <= bit_count + 1;
      
      // Once we have a complete byte
      if (bit_count == 7) begin
        bit_count <= 0;
        
        // Assemble the 32-bit word from 4 bytes (MSB first)
        case (rx_byte_phase)
          2'd0: rx_word[31:24] <= {rx_byte[6:0], spi_mosi_sync};
          2'd1: rx_word[23:16] <= {rx_byte[6:0], spi_mosi_sync};
          2'd2: rx_word[15:8]  <= {rx_byte[6:0], spi_mosi_sync};
          2'd3: begin
            rx_word[7:0] <= {rx_byte[6:0], spi_mosi_sync};
            // Complete 32-bit word received, store in sample buffer
            sample_buf[byte_count >> 2] <= {rx_word[31:8], rx_byte[6:0], spi_mosi_sync};
          end
        endcase
        
        // Update counters
        rx_byte_phase <= rx_byte_phase + 1;
        byte_count <= byte_count + 1;
      end
    end
    else if (state == WAIT_FFT && i_FFT_Valid) begin
      // Reset byte count for sending phase
      byte_count <= 0;
    end
    else if (state == SENDING && spi_clk_posedge) begin
      // Update byte count during sending phase
      if (bit_count == 7) begin
        byte_count <= byte_count + 1;
        bit_count <= 0;
      end
      else begin
        bit_count <= bit_count + 1;
      end
    end
  end
  
  // === Assert new_samples_ready signal when samples are ready ===
  always_ff @(posedge i_Clk or negedge i_Rst_L) begin
    if (!i_Rst_L)
      o_New_Samples_Ready <= 0;
    else if (state == RECEIVING && next_state == WAIT_FFT)
      o_New_Samples_Ready <= 1;  // Pulse high when all samples received
    else
      o_New_Samples_Ready <= 0;
  end
  
  // === Prepare FFT result bytes for transmission ===
  always_ff @(posedge i_Clk) begin
    if (state == WAIT_FFT && i_FFT_Valid) begin
      // Unpack 32 FFT results (32-bit each) into byte array for transmission
      for (int i = 0; i < 32; i++) begin
        fft_out_bytes[i*4]     <= i_FFT_Output[i][31:24]; // MSB first
        fft_out_bytes[i*4 + 1] <= i_FFT_Output[i][23:16];
        fft_out_bytes[i*4 + 2] <= i_FFT_Output[i][15:8];
        fft_out_bytes[i*4 + 3] <= i_FFT_Output[i][7:0];
      end
    end
  end
  
  // === SPI transmit logic ===
  logic [7:0] tx_shift_reg;
  logic [2:0] miso_bit_count;
  
  always_ff @(posedge i_Clk or negedge i_Rst_L) begin
    if (!i_Rst_L) begin
      tx_shift_reg <= 8'd0;
      miso_bit_count <= 3'd7;  // Start with MSB
    end
    else if (state == IDLE || i_SPI_CS_n) begin
      miso_bit_count <= 3'd7;
    end
    else if (state == SENDING) begin
      // Initialize tx_shift_reg with first byte when entering SENDING state
      if (state != next_state || (byte_count == 0 && miso_bit_count == 7)) begin
        tx_shift_reg <= fft_out_bytes[0];
      end
      // On SPI clock falling edge, shift out next bit
      else if (!spi_clk_sync && prev_spi_clk) begin
        if (miso_bit_count == 0) begin
          // Load next byte when current byte is sent
          tx_shift_reg <= fft_out_bytes[byte_count + 1];
          miso_bit_count <= 3'd7;
        end
        else begin
          // Shift register for next bit
          tx_shift_reg <= {tx_shift_reg[6:0], 1'b0};
          miso_bit_count <= miso_bit_count - 1;
        end
      end
    end
  end
  
  // MISO output assignment
  assign o_SPI_MISO = (state == SENDING && !spi_cs_sync) ? tx_shift_reg[7] : 1'bZ;
  
endmodule
