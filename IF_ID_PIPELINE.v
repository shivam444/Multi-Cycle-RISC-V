module IF_ID_PIPELINE#(parameter INSTRUCTION_LEN = 32, ADDRESS_SIZE = 6)(input clk, input rst, input [INSTRUCTION_LEN-1:0] instruction_in, input [(2**ADDRESS_SIZE)-1:0] instruction_ptr_in, input IF_FLUSH, input IF_ID_WRITE, output reg [INSTRUCTION_LEN-1:0] instruction_out, output reg [(2**ADDRESS_SIZE)-1:0] instruction_ptr_out);

	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			instruction_out <= 'b0;
			instruction_ptr_out <= 'b0;
		end
		else if(IF_FLUSH)begin
			instruction_out <= 'b0;
		end
		else if(IF_ID_WRITE)begin
			instruction_out <= instruction_in;
			instruction_ptr_out <= instruction_ptr_in;
		end
	end
endmodule