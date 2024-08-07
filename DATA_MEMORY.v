module DATA_MEMORY#(parameter ADDRESS_SIZE = 10, N = 64)(input clk, input rst, input mem_read,input mem_write, input [ADDRESS_SIZE - 1:0] rd_addr, input [ADDRESS_SIZE-1:0] wr_addr, input [N-1:0] data_in, output [N-1:0] data_out);

	reg [N-1:0]data_mem[(2**ADDRESS_SIZE)-1:0];
	wire [N-1:0] temp_data;
	integer i;
	
	assign data_out = mem_read ? data_mem[rd_addr] : 'b0;
	assign temp_data = data_in;
	
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			for(i = 0; i < (2**ADDRESS_SIZE); i = i + 1)begin
				data_mem[i] <= 'b0;
			end
		end
		else if(mem_write)begin
			data_mem[wr_addr] <= temp_data;
		end
	end
endmodule
	