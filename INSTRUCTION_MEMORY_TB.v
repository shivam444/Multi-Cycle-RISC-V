`timescale 1ns/1ps

module INSTRUCTION_MEMORY_TB;
	reg clk; 
	reg rst;
	reg [31:0]mem[1023:0];
	reg ins_write;
	reg [9:0] wr_addr;
	reg [31:0] instruction_in;
	reg [9:0] rd_addr;
	wire [31:0] instruction;
	localparam iterations = 1000;
	integer i,j,k,success;
	
	INSTRUCTION_MEMORY instruction_mem_dut(.clk(clk),.rst(rst),.ins_write(ins_write),.wr_addr(wr_addr),.instruction_in(instruction_in),.rd_addr(rd_addr),.instruction(instruction));
	
	always #5 clk = ~clk;
	
	initial begin
		clk = 1'b0;
		i = 0;
		j = 0;
		success = 0;
		rst = 1'b0;
		ins_write = 1'b1;
		wr_addr = 'b0;
		rd_addr = 'b0;
		instruction_in = 'b0;
		#100
		rst = 1'b1;
	end
	initial begin
		for(k = 0; k < 1024; k = k + 1)begin
			mem[k] = 'b0;
		end
	end
	
	always@(posedge clk)begin
		if(rst)begin
			if(j<1024)begin
				j <= j + 1;
				wr_addr <= $random%1024;
				instruction_in <= $random;
				mem[wr_addr] <= instruction_in;
			end
			else begin
				ins_write <= 1'b0;
				rd_addr <= $random%1024;
				i = i+1;
				if(instruction == mem[rd_addr])begin
					success = success + 1;
				end
			end
		end
	end
	
	always@*begin
		if(i > iterations)begin
			$display("success = %d/%d",success, iterations);
			#10
			$finish;
		end
	end
endmodule
			
				
			
			