module CONTROL_UNIT_TB;

	localparam INSTRUCTION_LEN = 32; 
	localparam CONTROL_LINE = 8;
	localparam iter= 1000;
	
	localparam R_FORMAT = 7'd51;
	localparam LOAD = 7'd3;
	localparam STORE = 7'd35;
	localparam BEQ = 7'd99;
	
	logic [INSTRUCTION_LEN-1:0] instruction; 
	logic [CONTROL_LINE-1:0] control;
	logic [CONTROL_LINE-1:0] control_exp;
	
	reg alu_src;
	reg mem_to_reg;
	reg reg_write;
	reg mem_read;
	reg mem_write;
	reg pc_src;
	reg [1:0] alu_op;
	
	int opcode[4]= '{51,3,35,99};
	int ins;
	int index;
	int i;

	CONTROL_UNIT#(.INSTRUCTION_LEN(INSTRUCTION_LEN),
					.CONTROL_LINE(CONTROL_LINE))
						
				control_unit_dut(.*);
				
	initial begin
		#100
		check;
		#10
		print;
		#10
		$finish;
	end
	
	task check;
		repeat(iter)begin
			index = $urandom%4;
			ins = opcode[index];
			instruction = {'b0,ins};
			
			
			case(ins)
				R_FORMAT : begin
								alu_src = 1'b0;
								mem_to_reg = 1'b0;
								reg_write = 1'b1;
								mem_read = 1'b0;
								mem_write = 1'b0;
								pc_src = 1'b0;
								alu_op = 2'b10;
							end
				LOAD : begin
								alu_src = 1'b1;
								mem_to_reg = 1'b1;
								reg_write = 1'b1;
								mem_read = 1'b0;
								mem_write = 1'b0;
								pc_src = 1'b0;
								alu_op = 2'b00;
						end
				STORE : begin
								alu_src = 1'b1;
								mem_to_reg = 1'bx;
								reg_write = 1'b0;
								mem_read = 1'b0;
								mem_write = 1'b1;
								pc_src = 1'b0;
								alu_op = 2'b00;
						end
				BEQ : begin
								alu_src = 1'b0;
								mem_to_reg = 1'bx;
								reg_write = 1'b0;
								mem_read = 1'b0;
								mem_write = 1'b0;
								pc_src = 1'b1;
								alu_op = 2'b01;
					end
				default : begin
								alu_src = 1'b1;
								mem_to_reg = 1'b1;
								reg_write = 1'b1;
								mem_read = 1'b0;
								mem_write = 1'b0;
								pc_src = 1'b0;
								alu_op = 2'b00;
						end
			endcase
			
			control_exp = {alu_op, alu_src, pc_src, mem_read, mem_write, reg_write, mem_to_reg};
			#5
			if(control === control_exp)begin
				i++;
			end
			else begin
				$display("%dth, iteration failed",i);
			end
			
		end
	endtask
	
	task print;
		if(i ==iter)begin
			$display("Success, passed = %d/%d", i,iter);
		end
		else begin
			$display("Failed, passed = %d/%d", i,iter);
		end
	endtask
	
endmodule