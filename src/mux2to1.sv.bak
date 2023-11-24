module mux2to1(
	input logic [23:0] sum,
	input logic [23:0] clock_tick,
	input logic sel,
	output logic [23:0] result);

	assign result = sel ? clock_tick : sum;
endmodule
