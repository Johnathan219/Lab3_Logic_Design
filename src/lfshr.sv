module lfshr (
  input wire clk,       // Clock signal
  input wire reset,   // Reset signal 
  input logic [23:0] data_in,
  output logic [23:0] lfsr_out // LFSR output
);

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      lfsr_out <= data_in;
    end else begin
      lfsr_out <= {(lfsr_out[0] ^ lfsr_out[1]), lfsr_out[23:1]};
    end
  end

endmodule

