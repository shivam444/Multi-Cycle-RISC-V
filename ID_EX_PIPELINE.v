module ID_EX_PIPELINE#(parameter DATA_LEN = 64, INSTRUCTION_LEN = 32, CONTROL_LINE_IN = 8,CONTROL_LINE_OUT = 8, ADDRESS_SIZE = 6 , INSTRUCTION_1_LEN = 10, INSTRUCTION_2_LEN = 5)
(input clk, input rst, input ID_FLUSH, input if_beq, input [DATA_LEN-1:0] data_1, input [DATA_LEN-1:0] data_2, input [DATA_LEN-1:0] imm_val, input [CONTROL_LINE_IN-1:0] control_in, input [(2**ADDRESS_SIZE)-1:0] instruction_ptr_in, input [INSTRUCTION_1_LEN-1:0] instruction_part_1, input [INSTRUCTION_2_LEN-1:0] instruction_part_2, input [INSTRUCTION_LEN-1:0] instruction_in, input predictor_val,
	output reg if_beq_out, output reg [CONTROL_LINE_OUT-1:0] control_out, output reg [DATA_LEN-1:0] data_1_out, output reg [DATA_LEN-1:0] data_2_out, output reg [(2**ADDRESS_SIZE)-1:0] instruction_ptr_out, output reg [DATA_LEN-1:0] imm_val_out, output reg [INSTRUCTION_1_LEN-1:0] instruction_part_1_out, output reg [INSTRUCTION_2_LEN-1:0] instruction_part_2_out,output reg [INSTRUCTION_LEN-1:0] instruction_out, output reg predictor_out);
	
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			control_out <= 'b0;
			data_1_out <= 'b0;
			data_2_out <= 'b0;
			instruction_ptr_out <= 'b0;
			imm_val_out <= 'b0;
			instruction_part_1_out <= 'b0;
			instruction_part_2_out <= 'b0;
			instruction_out <= 'b0;
			predictor_out <= 'b0;
			if_beq_out <= 'b0;
		end
		else if(ID_FLUSH)begin
			control_out <= 'b0;
			data_1_out <= 'b0;
			data_2_out <= 'b0;
			instruction_ptr_out <= 'b0;
			imm_val_out <= 'b0;
			instruction_part_1_out <= 'b0;
			instruction_part_2_out <= 'b0;
			instruction_out <= 'b0;
			if_beq_out <= 'b0;
			predictor_out <= predictor_val;
		end
		else begin
			control_out <= control_in[CONTROL_LINE_IN-1: CONTROL_LINE_IN-CONTROL_LINE_OUT];
			data_1_out <= data_1;
			data_2_out <= data_2;
			instruction_ptr_out <= instruction_ptr_in;
			imm_val_out <= imm_val;
			instruction_part_1_out <= instruction_part_1;
			instruction_part_2_out <= instruction_part_2;
			instruction_out <= instruction_in;
			if_beq_out <= if_beq;
			predictor_out <= predictor_val;
		end
	end
	
endmodule