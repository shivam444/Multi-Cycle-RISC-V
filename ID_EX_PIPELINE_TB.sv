module ID_EX_PIPELINE_TB;
	localparam DATA_LEN = 64; 
	localparam CONTROL_LINE_IN = 7;
	localparam CONTROL_LINE_OUT = 5; 
	localparam ADDRESS_SIZE = 6 ; 
	localparam INSTRUCTION_1_LEN = 4; 
	localparam INSTRUCTION_2_LEN = 5; 
	
	localparam iter = 10;
	
	bit clk; always #5 clk = ~clk;
	bit rst; initial #100 rst = 1'b1;
	logic [DATA_LEN-1:0] data_1; 
	logic [DATA_LEN-1:0] data_2; 
	logic [DATA_LEN-1:0] imm_val; 
	logic [CONTROL_LINE_IN-1:0] control_in; 
	logic [(2**ADDRESS_SIZE)-1:0] instruction_ptr_in; 
	logic [INSTRUCTION_1_LEN-1:0] instruction_part_1; 
	logic [INSTRUCTION_2_LEN-1:0] instruction_part_2;
	logic [CONTROL_LINE_OUT-1:0] control_out;
	logic [DATA_LEN-1:0] data_1_out; 
	logic [DATA_LEN-1:0] data_2_out; 
	logic [(2**ADDRESS_SIZE)-1:0] instruction_ptr_out; 
	logic [DATA_LEN-1:0] imm_val_out; 
	logic [INSTRUCTION_1_LEN-1:0] instruction_part_1_out; 
	logic [INSTRUCTION_2_LEN-1:0] instruction_part_2_out;
	
	int i;
	
	ID_EX_PIPELINE#(.DATA_LEN(DATA_LEN),
					.CONTROL_LINE_IN(CONTROL_LINE_IN),
					.CONTROL_LINE_OUT(CONTROL_LINE_OUT),
					.ADDRESS_SIZE(ADDRESS_SIZE),
					.INSTRUCTION_1_LEN(INSTRUCTION_1_LEN),
					.INSTRUCTION_2_LEN(INSTRUCTION_2_LEN))
					
					id_ex_pipeline_dut(.*);
	
	initial begin
		repeat(10)@(posedge clk);
		check;
		repeat(5)@(posedge clk);
		print;
		repeat(2)@(posedge clk);
		$finish;
	end
	
	
	
	task check;
		repeat(iter)begin
			@(posedge clk);
			data_1 = $urandom;
			data_2 = $urandom;
			imm_val = $urandom;
			control_in = $urandom;
			instruction_ptr_in = $urandom;
			instruction_part_1 = $urandom;
			instruction_part_2 = $urandom;
			
			repeat(2)@(posedge clk);
			if((data_1_out == data_1) && (data_2_out == data_2) && (control_out == control_in[CONTROL_LINE_IN-1: CONTROL_LINE_IN-CONTROL_LINE_OUT]) &&
				(instruction_ptr_out == instruction_ptr_in) && (imm_val_out == imm_val) && (instruction_part_1_out == instruction_part_1) &&
				(instruction_part_2_out == instruction_part_2))begin
					i++;
			end
			else begin
				$display("%d, iteration failed", i);
			end
		end
	endtask
	
	task print;
		if(i ==iter)begin
			$display("Success, all test cases passed");
		end
		else begin
			$display("failed");
		end
	endtask
	
endmodule
			
			
	