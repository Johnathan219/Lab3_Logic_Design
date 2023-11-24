module mux2to1(
	input logic [23:0] data,
	input logic [23:0] fifolen,
	input logic sel,
	output logic [23:0] result);

	assign result = sel ? data : fifolen;
endmodule
