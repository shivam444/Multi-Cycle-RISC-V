`timescale 1ns/1ps

module RISCV_PROCESSOR_TB;
	reg clk;
	reg rst;
	reg ins_write;
	reg [31:0] instruction_in;
	wire [63:0] res;
	
	RISCV_PROCESSOR riscv_dut(.clk(clk),.rst(rst),.ins_write(ins_write),.instruction_in(instruction_in),.res(res));
	
	always #5 clk = ~clk;
	
	initial begin
		clk = 1'b0;
		rst = 1'b0;
		instruction_in = 32'b00000000000100000000000111100011;
		ins_write = 1'b1;
		#100
		rst = 1'b1;
		#20000
		ins_write = 1'b0;
		#10000
		$finish;
	end
	
	initial begin
		$monitor("Result = %d", res);
	end
endmodule