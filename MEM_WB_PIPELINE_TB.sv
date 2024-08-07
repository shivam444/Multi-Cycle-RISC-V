module MEM_WB_PIPELINE_TB;
	
	localparam DATA_LEN = 64; 
	localparam CONTROL_LINE = 2; 
	localparam INSTRUCTION_PART = 5;
	
	localparam iter = 10;
	
	bit clk; always #5 clk = ~clk;
	bit rst; 
	logic [DATA_LEN-1:0] rd_data; 
	logic [CONTROL_LINE-1:0] control_in; 
	logic [DATA_LEN-1:0] addr; 
	logic [INSTRUCTION_PART-1:0] instruction_part;
	logic [CONTROL_LINE-1:0] control_out; 
	logic [DATA_LEN-1:0] rd_data_out; 
	logic [DATA_LEN-1:0] addr_out; 
	logic [INSTRUCTION_PART-1:0] instruction_part_out;
	
	int i;
	
	MEM_WB_PIPELINE#(.DATA_LEN(DATA_LEN),
						.CONTROL_LINE(CONTROL_LINE),
						.INSTRUCTION_PART(INSTRUCTION_PART))
						
					mem_wb_pipeline_dut(.*);
					
	
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
			rd_data = $urandom;
			control_in = $urandom;
			addr = $urandom;
			instruction_part = $urandom;
		
			repeat(2)@(posedge clk);
			
			if((rd_data_out == rd_data) && (control_out == control_in) && (addr_out == addr) && (instruction_part_out == instruction_part))begin
				i++;
			end
			else begin
				$display("%d,th iteration failed", i);
			end
		end
	endtask
	
	task print;
		if(i == iter)begin
			$display("Succes, passed = %d/%d", i,iter);
		end
		else begin
			$display("Succes, passed = %d/%d", i,iter);
		end
	endtask
	
endmodule
		
	