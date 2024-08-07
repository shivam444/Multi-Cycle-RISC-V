module IF_ID_PIPELINE_TB;
	
	localparam ADDRESS_SIZE = 6; 
	localparam INSTRUCTION_LEN = 32;
	localparam iter = 1000;
	
	bit clk; always #5 clk = ~clk;
	bit rst; initial #100 rst = 1'b1;
	logic [INSTRUCTION_LEN-1:0] instruction_in; 
	logic [(2**ADDRESS_SIZE)-1:0] instruction_ptr_in; 
	logic IF_FLUSH; 
	logic IF_ID_WRITE; 
	logic [INSTRUCTION_LEN-1:0] instruction_out; 
	logic [(2**ADDRESS_SIZE)-1:0] instruction_ptr_out;
	
	logic [INSTRUCTION_LEN-1:0] instruction_temp;
	logic [(2**ADDRESS_SIZE)-1:0] instruction_ptr_temp;
	
	int i;
	
	IF_ID_PIPELINE #(.INSTRUCTION_LEN(INSTRUCTION_LEN),
						.ADDRESS_SIZE(ADDRESS_SIZE))
						if_id_pipeline_dut(.*);
	
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
			instruction_in = $urandom;
			instruction_ptr_in = $urandom;
			IF_FLUSH = 'b0;
			IF_ID_WRITE = ~IF_FLUSH;
			instruction_temp = instruction_out;
			
			repeat(2)@(posedge clk);
			if(IF_FLUSH)begin
				if(instruction_out == 'b0)begin
					i++;
				end
				else begin
					$display("%d Iteration failed", i);
				end
			end
			else if(IF_ID_WRITE)begin
				if((instruction_out == instruction_in) && (instruction_ptr_out == instruction_ptr_in))begin
					i++;
				end
				else begin
					$display("%d Iteration failed, exp = %d, got = %d", i, instruction_in, instruction_out);
				end
			end
			else begin
				if((instruction_out == instruction_temp) && (instruction_ptr_out == instruction_ptr_temp))begin
					i++;
				end
				else begin
					$display("%d Iteration failed", i);
				end
			end
		end
		
	endtask
	
	task print;
		if(i == iter)begin
			$display("Success");
		end
		else begin
			$display("Failed");
		end
	endtask
	
endmodule
			
			