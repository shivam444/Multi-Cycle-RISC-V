module EX_MEM_PIPELINE#(parameter CONTROL_LINE = 5, DATA_LEN = 64, INSTRUCTION_PART  = 5)
						(input clk, input rst , input EX_FLUSH, input if_beq, input [DATA_LEN-1:0] alu_val, input [DATA_LEN-1:0] wr_addr, input [INSTRUCTION_PART-1:0] instruction_part, input [CONTROL_LINE-1:0] control_in, input zero_in, input predictor_val,
						output reg if_beq_out, output reg [CONTROL_LINE-1:0] control_out, output reg zero_out, output reg [DATA_LEN-1:0] alu_val_out, output reg [DATA_LEN-1:0] wr_addr_out, output reg [INSTRUCTION_PART-1:0] instruction_part_out, output reg predictor_out);
						
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			control_out <= 'b0;
			zero_out <= 'b0;
			alu_val_out <= 'b0;
			wr_addr_out <= 'b0;
			instruction_part_out <= 'b0;
			predictor_out <= 'b0;
			if_beq_out <= 'b0;
		end
		else if(EX_FLUSH)begin
			control_out <= 'b0;
			zero_out <= 'b0;
			alu_val_out <= 'b0;
			wr_addr_out <= 'b0;
			instruction_part_out <= 'b0;
			predictor_out <= ~predictor_out;
			if_beq_out <= 'b0;
		end
		else begin
			control_out <= control_in;
			zero_out <= zero_in;
			alu_val_out <= alu_val;
			wr_addr_out <= wr_addr;
			instruction_part_out <= instruction_part;
			predictor_out <= predictor_val;
			if_beq_out <= if_beq;
		end
	end
endmodule