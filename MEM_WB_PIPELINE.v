module MEM_WB_PIPELINE#(parameter DATA_LEN = 64, CONTROL_LINE = 2, INSTRUCTION_PART = 5)
						(input clk, input rst, input [DATA_LEN-1:0] rd_data, input [CONTROL_LINE-1:0] control_in, input [DATA_LEN-1:0] addr, input [INSTRUCTION_PART-1:0] instruction_part,
						output reg [CONTROL_LINE-1:0] control_out, output reg [DATA_LEN-1:0] rd_data_out, output reg [DATA_LEN-1:0] addr_out, output reg [INSTRUCTION_PART-1:0] instruction_part_out);
						
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			control_out <= 'b0;
			rd_data_out <= 'b0;
			addr_out <= 'b0;
			instruction_part_out <= 'b0;
		end
		else begin
			control_out <= control_in;
			rd_data_out <= rd_data;
			addr_out <= addr;
			instruction_part_out <= instruction_part;
		end
	end
	
endmodule
										