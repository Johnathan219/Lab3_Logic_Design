module fifoctrl
    (
     clkw, //clock write
     clkr, //clock read
     rst,
     
     fiford,    // FIFO control
     fifowr,

     fifofull,  // high when fifo full
     notempty,  // high when fifo not empty
     fifolen,   // fifo length

                // Connect to memories
     write,     // enable to write memories
     wraddr,    // write address of memories
     read,      // enable to read memories
     rdaddr     // read address of memories
     );

parameter ADDRBIT = 5;
parameter LENGTH = 32;

input   clkw,
        clkr,
        rst,
        fiford,
        fifowr;

output  fifofull,
        notempty;

output [ADDRBIT:0] fifolen;

output  write;
output  read;

output reg [ADDRBIT:0] wraddr;
output reg [ADDRBIT:0] rdaddr;

wire fifofull;
assign fifofull			=	({~wraddr[5],wraddr[4:0]} == rdaddr);

wire fifoempt;
assign fifoempt 		=	rdaddr == wraddr;

wire    notempty;
assign  notempty    =   !fifoempt;
assign  fifolen     =   (wraddr >= rdaddr) ? (wraddr - rdaddr) : (5'd31 + wraddr - rdaddr);

wire    write;
assign  write       =   (fifowr& !fifofull);

wire    read;
assign  read        =   (fiford& !fifoempt);

always @(posedge clkr or posedge rst)begin
    if(rst) begin
		rdaddr <= 5'd0;
	 end
    else begin
		 if(read) begin
		rdaddr <= rdaddr + 5'd1;
		end
    end
end

always @(posedge clkw or posedge rst)begin
    if(rst) begin
		wraddr <= 5'd0;
	 end
    else begin
		 if(write) begin
		wraddr <= wraddr + 5'd1;
		end
	end
end

endmodule

