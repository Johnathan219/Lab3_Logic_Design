`timescale 1ps/1ps

module tb_assert;
// Input variables
	reg CLOCK_50;
	logic i_clk; 
	logic o_clk;
	reg SW;
	reg [2:0] KEY;

// Output variables
	logic [2:0] LEDR;
	logic [5:0] fifolen;
	wire [6:0] HEX5;
	wire [6:0] HEX4;
	wire [6:0] HEX3;
	wire [6:0] HEX2;
	wire [6:0] HEX1;
	wire [6:0] HEX0;  
	
// Instantiate the module under test
  top_lab3 dut (
	 .CLOCK_50(CLOCK_50),
    .SW(SW),
    .KEY(KEY),
	 .fifolen(fifolen),
    .LEDR(LEDR),
	 .HEX5(HEX5),
	 .HEX4(HEX4),
	 .HEX3(HEX3),
	 .HEX2(HEX2),
	 .HEX1(HEX1),
	 .HEX0(HEX0)
  );
  
// Decleare internal variable
	logic [4:0] wraddr;
	logic [4:0] rdaddr;
	logic [4:0] rd_ptr;
	logic [4:0] wr_ptr;
	logic [23:0] o_data;
	logic [23:0] i_data;
	logic o_empty;
	logic o_full;
	logic rd_en;
	logic wr_en;
	logic i_rst_n;
  
	assign i_clk = dut.i_clk;
	assign o_clk = dut.o_clk;
	assign i_data = dut.data_in;
	assign wraddr = dut.wraddr;
	assign rdaddr = dut.rdaddr;
	assign i_rst_n = KEY[2];
	assign rd_en = ~KEY[1];
	assign wr_en = ~KEY[0];  
	assign wr_ptr = wraddr;
	assign rd_ptr = rdaddr;
	assign o_data = dut.data_out;
	assign o_empty = !dut.notempty;
	assign o_full = dut.fifofull;

// Test case 1: Check Clock generation
	property async_rst_startup;
		@(posedge i_clk) !i_rst_n 
		|-> ##1 (wraddr==0 && rdaddr == 0 && o_empty); // in one cycle if there is the rst signal, all wraddr, raddr, and empty will execute
	endproperty
 	assert property (async_rst_startup);
	
// Test 2: rst check in general
	property async_rst_chk;
		@(negedge i_rst_n) 1'b1 
		|-> ##1 @(posedge i_clk) (wraddr==0 && rdaddr == 0 && o_empty);
	endproperty
	assert property (async_rst_chk);
	
// Test case 3: Check data written at a location is the same data read when read_ptr reaches that location
	sequence rd_detect(ptr);
		##[0:$] (rd_en && !o_empty && (rd_ptr == ptr));
	endsequence
 
	property data_wr_rd_chk(wrPtr);
		// local variable
		integer ptr, data;
		@(posedge i_clk) disable iff(!i_rst_n)
		(wr_en && !o_full, ptr = wrPtr, data = i_data, $display ($time, " wr_ptr=%h, i_fifo=%h",wr_ptr, i_data)) 
		|-> ##1 first_match(rd_detect(ptr), $display ($time, " rd_ptr=%h,o_fifo=%h",rd_ptr, o_data)) ##0 o_data == data;
	endproperty
	assert property (data_wr_rd_chk(wr_ptr));
	
// Test case 4: Never write to FIFO if it's Full!
	property dont_write_if_full;
		@(posedge i_clk) disable iff(!i_rst_n) wr_en && o_full 
		|-> ##1 wr_ptr == $past(wr_ptr);
	endproperty
	assert property (dont_write_if_full);
 
// Test case 5: Never read from an Empty FIFO
	property dont_read_if_empty;
		@(posedge o_clk) disable iff(!i_rst_n) rd_en && o_empty 
		|-> ##1 $stable(rd_ptr);
	endproperty
	assert property (dont_read_if_empty);

// Test case 6: Write_ptr should only increment by 1
	property inc_rd_one;
		@(posedge o_clk) disable iff(!i_rst_n) rd_en && !o_empty 
		|-> ##1 (rd_ptr - 1'b1 == $past(rd_ptr));
	endproperty
	assert property (inc_rd_one);
 
// Test case 7: Read_ptr should only increment by 1 
	property inc_wr_one;
		@(posedge i_clk) disable iff(!i_rst_n) wr_en && !o_full 
		|-> ##1 (wr_ptr - 1'b1 == $past(wr_ptr));
	endproperty
	assert property (inc_wr_one);
 
// Test case 8: Assertion for FIFO empty from the beginning
	property p_empty;
		@(posedge o_clk) disable iff(!i_rst_n) rd_en && o_empty |-> ##1 (fifolen == 0);
	endproperty
	assert property(p_empty);

// Test case 9: Assertion for FIFO full from the beginning
	property p_full;
		@(posedge i_clk) disable iff(!i_rst_n) wr_en && o_full |-> ##1 (rd_ptr == wr_ptr);
	endproperty
	assert property(p_full);

// Test case 10: Check fifolen not increase when the ffio is full
	property fifolen_not_increase;
		@(posedge i_clk) disable iff(!i_rst_n) wr_en && o_full |-> ##1 (fifolen == $past(fifolen));
	endproperty
	assert property(fifolen_not_increase);
	
// Test case 11: Check fifolen not decrease when the ffio is full
	property fifolen_not_decrease;
		@(posedge o_clk) disable iff(!i_rst_n) rd_en && o_empty |-> ##1 (fifolen == 0);
	endproperty
	assert property(fifolen_not_decrease);
	
// Initial clock
	initial begin
		forever begin
			#10 CLOCK_50 = ~CLOCK_50;
		end
	end


  initial begin
    // Initialize inputs
    SW = 0;
    KEY = 3'b111;
	 CLOCK_50 = 0;
	 
	 #10
	 @(posedge i_clk);
    KEY[2] =  1'b0 ;
	 #20
	 @(posedge i_clk);
	 KEY[2] =  1'b1 ;
	 #10
	 @(posedge i_clk);
    KEY[2] =  1'b0 ;
	 #20
	 @(posedge i_clk);
	 KEY[2] =  1'b1 ;
	 
	 #50;
	 @(posedge o_clk);
    KEY[1] = 1'b0;
	 @(posedge o_clk);
	 KEY[1] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge o_clk);
    KEY[1] = 1'b0;
	 @(posedge o_clk);
	 KEY[1] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge o_clk);
    KEY[1] = 1'b0;
	 @(posedge o_clk);
	 KEY[1] = 1'b1;	

	 @(posedge o_clk);
    KEY[1] = 1'b0;
	 @(posedge o_clk);
	 KEY[1] = 1'b1;
	 
	 @(posedge o_clk);
    KEY[1] = 1'b0;
	 @(posedge o_clk);
	 KEY[1] = 1'b1;	

	 @(posedge o_clk);
    KEY[1] = 1'b0;
	 @(posedge o_clk);
	 KEY[1] = 1'b1;
	 
	 @(posedge o_clk);
    KEY[1] = 1'b0;
	 @(posedge o_clk);
	 KEY[1] = 1'b1;	

	 @(posedge o_clk);
    KEY[1] = 1'b0;
	 @(posedge o_clk);
	 KEY[1] = 1'b1;

	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	  
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	  
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;
	 
	 @(posedge i_clk);
	 KEY[0] = 1'b0;
	 @(posedge i_clk);
	 KEY[0] = 1'b1;

    // Wait for simulation to finish
    #1000;
    $stop;
  end
endmodule
