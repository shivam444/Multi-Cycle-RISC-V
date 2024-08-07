module INSTRUCTION_MEMORY#(parameter ADDRESS_SIZE = 10, N = 32)(input clk, input rst, input ins_write,input[ADDRESS_SIZE-1:0]wr_addr, input [N-1:0] instruction_in, input [ADDRESS_SIZE-1:0] rd_addr, output [N-1:0] instruction);
	
	reg [N-1:0]instruction_memory[(2**ADDRESS_SIZE)-1:0];
	integer i;
	
	assign instruction = ins_write?'b0:instruction_memory[rd_addr];
	
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			for(i = 0; i < (2**ADDRESS_SIZE); i= i + 1)begin
				instruction_memory[i] <= 'b0;
			end
		end
		else if(ins_write) begin
			instruction_memory[wr_addr] <= instruction_in;
		end
	end
endmodule