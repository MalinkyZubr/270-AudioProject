module note_lookup_linear (
  input  logic [4:0] bin, // Bins based on 1024hz and sample size of 32.
  output logic [2:0] note
);

    always_comb begin
        case (bin)
            5'd8:  note_code = 3'd0; // C4 261.63
            5'd9:  note_code = 3'd1; // D4 293.66
            5'd10: note_code = 3'd2; // E4 329.63
            5'd11: note_code = 3'd3; // F#4 369.99
            5'd12: note_code = 3'd4; // G4 392.00
            5'd13: note_code = 3'd5; // A4 440.00
            5'd14: note_code = 3'd6; // A#4 466.16
            5'd15: note_code = 3'd7; // B4 493.88
            default: note_code = 3'd0;
        endcase
    end

endmodule
