`timescale 1ns/1ps

module EX_MEM_PIPELINE_TB;
	
	localparam CONTROL_LINE = 5; 
	localparam DATA_LEN = 64; 
	localparam INSTRUCTION_PART  = 5;
	localparam iter = 10;
	
	bit clk; always #5 clk = ~clk;
	bit rst ; 
	logic [DATA_LEN-1:0] alu_val; 
	logic [DATA_LEN-1:0] wr_addr; 
	logic [INSTRUCTION_PART-1:0] instruction_part; 
	logic [CONTROL_LINE-1:0] control_in; 
	logic zero_in;
	logic [CONTROL_LINE-1:0] control_out; 
	logic zero_out; 
	logic [DATA_LEN-1:0] alu_val_out; 
	logic [DATA_LEN-1:0] wr_addr_out; 
	logic [INSTRUCTION_PART-1:0] instruction_part_out;
	
	int i;
	
	EX_MEM_PIPELINE#(.CONTROL_LINE(CONTROL_LINE),
						.DATA_LEN(DATA_LEN),
						.INSTRUCTION_PART(INSTRUCTION_PART))
						
					ex_mem_pipeline_dut(.*);
	
	initial begin
		#100
		rst = 1'b1;
		repeat(2)@(posedge clk);
		check;
		repeat(2)@(posedge clk);
		print;
		repeat(2)@(posedge clk);
		$finish;
	end
	
	task check;
		repeat(iter)begin
			@(posedge clk);
			alu_val = $urandom;
			wr_addr = $urandom;
			instruction_part = $urandom;
			control_in = $urandom;
			zero_in = $urandom;
			
			repeat(2)@(posedge clk);
			
			if((alu_val_out == alu_val) && (zero_out == zero_in) && (control_out == control_in) && (wr_addr_out == wr_addr) && (instruction_part_out == instruction_part))begin
				i++;
			end
			else begin
				$display("%d,th iteration failed",i);
			end
		end
	endtask
	
	task print;
		if(i == iter)begin
			$display("Succes, %d/%d passed", i,iter);
		end
		else begin
			$display("failed, %d/%d passed", i,iter);
		end
	endtask
		
endmodule
	