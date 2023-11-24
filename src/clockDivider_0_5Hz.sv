module clockDivider_0_5Hz(
  input wire clk_in,
  output reg CLOCK_2SEC = 0
);

  reg [31:0] counter = 32'd0;

  always @(posedge clk_in) begin
    if (counter == 32'd0) begin
//      counter <= 32'd24999999;  // Divide the clock by 25000000
		counter <= 32'd249;  // Divide the clock by 25000000
      CLOCK_2SEC <= ~CLOCK_2SEC;  // Generate the divided clock
    end
    else begin
      counter <= counter - 32'd1;
    end
  end

endmodule
