module clockDivider_1Hz(
  input wire clk_in,
  output reg CLOCK_2SEC = 0
);

  reg [31:0] counter = 32'd0;

  always @(posedge clk_in) begin
    if (counter == 32'd0) begin
//      counter <= 32'd49999999;  // Divide the clock by 50000000
		counter <= 32'd499;  // Divide the clock by 50000000
      CLOCK_2SEC <= ~CLOCK_2SEC;  // Generate the divided clock
    end
    else begin
      counter <= counter - 32'd1;
    end
  end

endmodule
