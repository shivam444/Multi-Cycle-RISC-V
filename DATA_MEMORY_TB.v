`timescale 1ns/1ps

module DATA_MEMORY_TB;
	reg clk; 
	reg rst;
	reg [9:0] rd_addr;
	reg [9:0] wr_addr;
	reg mem_read;
	reg mem_write;
	reg [63:0] data_in;
	wire [63:0] data_out;
	reg [63:0] data_check;
	localparam iterations = 1000;
	integer i,success;
	
	DATA_MEMORY data_mem_dut(.clk(clk),.rst(rst),.mem_read(mem_read),.mem_write(mem_write),.rd_addr(rd_addr),.wr_addr(wr_addr),.data_in(data_in),.data_out(data_out));
	
	always #5 clk = ~clk;
	
	initial begin
		success = 0;
		i = 0;
		clk = 1'b0;
		rst = 1'b0;
		rd_addr = 'b0;
		wr_addr = 'b0;
		mem_read = 1'b0;
		mem_write = 1'b0;
		data_in = 'b0;
		data_check = 'b0;
		#100
		rst = 1'b1;
	end
	
	always@(posedge clk)begin
		if(rst)begin
			data_in <= $random;
			wr_addr <= $random%1024;
			mem_write <= 1'b1;
			mem_read <= ~mem_read;
			if(~mem_read)begin
				data_check <= data_in;
			end
			else begin
				data_check <= 'b0;
				i = i + 1;
			end
			if(mem_read && (data_check == data_out))begin
				success = success + 1;
			end
			rd_addr <= wr_addr;
			
		end
	end
	always@*begin
		if(i== iterations)begin
			$display("Success = %d/%d",success,iterations);
			#10
			$finish;
		end
	end
	
endmodule
	
	
			
		