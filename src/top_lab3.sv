//top level file of your Lab 3
module top_lab3 (
	input  logic CLOCK_50,
   input  logic SW,
   input  logic [2:0] KEY,
	output logic [5:0] fifolen,
	output logic [2:0] LEDR,
   output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
	);
	
	logic write;
	logic read;
	logic [4:0] wraddr;
	logic [4:0] rdaddr;
	logic notempty;
	logic empty;
	logic fifofull;
	logic i_clk;
	logic o_clk;
	logic [23:0] data_in;
	logic [23:0] result;
	logic [23:0] data_out;
	logic [23:0] fifolenExtend;
	
	clockDivider_0_5Hz	clkw	(CLOCK_50, o_clk);
	clockDivider_1Hz		clkr	(CLOCK_50, i_clk);
	lfshr						ran (i_clk, ~KEY[2],  24'b01011010110000100110110010,data_in);
	RAM 		memory 	  (data_in, rdaddr, ~o_clk, read, wraddr, i_clk, write, data_out);
	fifoctrl controller (i_clk, o_clk, ~KEY[2], ~KEY[1], ~KEY[0], fifofull, notempty, fifolen, write, wraddr, read, rdaddr);

	assign empty = ~notempty;
	assign LEDR[2] = empty;
	assign LEDR[1] = notempty;
   assign LEDR[0] = fifofull;
	assign fifolenExtend = {18'd0,fifolen};
	
// Mux select fifolen and data_out	
	mux2to1 select (data_out, fifolenExtend, SW, result);
	
// Binary to hex display
	bcdtohex h5 (result[23:20], HEX5);
	bcdtohex h4 (result[19:16], HEX4);
	bcdtohex h3 (result[15:12], HEX3);
	bcdtohex h2 (result[11:8], HEX2);
	bcdtohex h1 (result[7:4], HEX1);
	bcdtohex h0 (result[3:0], HEX0);
endmodule


