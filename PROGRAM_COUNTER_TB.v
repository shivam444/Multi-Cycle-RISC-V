`timescale 1ns/1ps

module PROGRAM_COUNTER_TB;

	reg clk;
	reg rst;
	reg pc_src;
	reg [63:0] offset_addr;
	wire [63:0] instruction_ptr;
	reg [63:0] instruction_ptr_exp;
	reg [63:0] instruction_ptr_exp_next;
	localparam iterations = 1000;
	integer i, success;
	
	PROGRAM_COUNTER pc_dut(.clk(clk),.rst(rst),.pc_src(pc_src),.offset_addr(offset_addr),.instruction_ptr(instruction_ptr));
	
	always #5 clk = ~clk;
	
	initial begin
		success = 0;
		i = 0;
		clk = 1'b0;
		rst = 1'b0;
		pc_src = 1'b0;
		offset_addr = 'b0;
		#207
		rst = 1'b1;
	end
	
	always@(posedge clk)begin
		if(rst)begin
			pc_src = $random%2;
			offset_addr = $random;
			i = i+1;
			if(instruction_ptr == instruction_ptr_exp)begin
				success = success + 1;
			end
		end
	end
	
	always@*begin
		if(pc_src)begin
			instruction_ptr_exp_next = instruction_ptr + (offset_addr << 1);
		end
		else begin
			instruction_ptr_exp_next = instruction_ptr_exp + 'd4;
		end
	end
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			instruction_ptr_exp <= 'b0;
		end
		else begin
			instruction_ptr_exp <= instruction_ptr_exp_next;
		end
	end
	
	always@*begin
		if(i == iterations)begin
			$display("Success = %d/%d",success, iterations);
			#7
			$finish;
		end
	end
endmodule