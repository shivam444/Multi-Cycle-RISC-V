module CONTROL_UNIT#(parameter INSTRUCTION_LEN = 32, CONTROL_LINE = 8)(input [INSTRUCTION_LEN-1:0] instruction, output [CONTROL_LINE-1:0] control);
	
	localparam R_FORMAT = 7'd51;
	localparam LOAD = 7'd3;
	localparam STORE = 7'd35;
	localparam BEQ = 7'd99;
	
	reg alu_src;
	reg mem_to_reg;
	reg reg_write;
	reg mem_read;
	reg mem_write;
	reg pc_src;
	reg [1:0] alu_op;
	
	always@*begin
		case(instruction[6:0])
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
	end
	
	assign control = {alu_op, alu_src, pc_src, mem_read, mem_write, reg_write, mem_to_reg};
	
endmodule