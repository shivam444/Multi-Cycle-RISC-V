`timescale 1ns/1ps

module REGISTER_FILE_TB;
	
	reg clk; 
	reg rst;
	reg reg_write;
	reg [63:0]mem[31:0];
	reg [4:0] rd_addr_1;
	reg [4:0] rd_addr_2;
	reg [4:0] wr_addr;
	reg [63:0] data;
	wire [63:0] rd_data_1;
	wire [63:0] rd_data_2;
	integer i,j, success;
	localparam iterations = 1000;
	reg [63:0] rd_data_1_exp;
	reg [63:0] rd_data_2_exp;
	reg [63:0] temp_data;
	
	
	REGISTER_FILE register_dut(.clk(clk),.rst(rst),.reg_write(reg_write),.rd_addr_1(rd_addr_1),.rd_addr_2(rd_addr_2),.wr_addr(wr_addr),.data(data),.rd_data_1(rd_data_1),.rd_data_2(rd_data_2));
	
	always #5 clk = ~clk;
	
	initial begin
		success = 0;
		i = 0;
		clk = 1'b0;
		rst = 1'b0;
		#15
		rst = 1'b1;
	end
		
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			rd_addr_1 = 'b0;
			rd_addr_2 = 'b1;
			wr_addr = 'b10;
			reg_write = 'b0;
			data = 'b0;
		end
		else begin
			rd_addr_1 = $random % 32;
			rd_addr_2 = rd_addr_1 + 1'b1;
			wr_addr = rd_addr_1 + 2'b10;
			reg_write = $random % 2;
			data = $random;
			i = i+1;
		end
	end
	
	always@*begin
		if(reg_write)begin
			temp_data = data;
		end
		else begin
			temp_data = mem[wr_addr];
		end
	end
	
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			for(j = 0; j < 32; j = j + 1)begin
				mem[j] <= 'b0;
			end
		end
		else begin
			mem[wr_addr] <= temp_data;
		end
	end
	always@(posedge clk or negedge rst)begin
		rd_data_1_exp <= mem[rd_addr_1];
		rd_data_2_exp <= mem[rd_addr_2];
	end
	
	always@(posedge clk) begin
		if(((rd_data_1 ^ rd_data_1_exp) == 0) && ((rd_data_2 ^ rd_data_2_exp) == 0))begin
			success <= success + 1;
		end
	end
	
	always@*begin
		if(i > iterations)begin
			$display("Success = %d/%d", success, iterations);
			#4
			$finish;
		end
	end
endmodule
	
	
			
			
			