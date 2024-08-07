module ALU_mod#(parameter INSTRUCTION_ADDR_SIZE = 5, N = 64)(input [(2**INSTRUCTION_ADDR_SIZE)-1:0] instruction, input [1:0] alu_op, input [N-1:0] data_1, input [N-1:0] data_2, output reg [N-1:0] data_out);
	
	reg [3:0] alu_control;
	wire [6:0] funct7;
	wire[2:0] funct3;
	
	assign funct7 = instruction[31:25];
	assign funct3 = instruction[14:12];
	
	always@*begin
		case(alu_op)
			2'b00: alu_control = 4'b0010;
			2'b01: alu_control = 4'b0110;
			2'b10: begin
					case({funct7,funct3})
						10'b0000000000: alu_control = 4'b0010;
						10'b0100000000: alu_control = 4'b0110;
						10'b0000000111: alu_control = 4'b0000;
						10'b0000000110: alu_control = 4'b0001;
						default : alu_control = 'bx;
                    endcase
                    end              
			default: alu_control = 'bx;
		endcase
	end
	
	always@*begin
		case(alu_control)
			4'b0000: data_out = data_1 & data_2;
			4'b0001: data_out = data_1 | data_2;
			4'b0010: data_out = data_1 + data_2;
			4'b0110: data_out = data_1 - data_2;
			default: data_out = 'b0;
		endcase
	end
	
endmodule