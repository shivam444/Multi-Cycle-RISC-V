module FORWARDING_UNIT#(parameter ADDRESS_LEN = 5, CONTROL_LINE = 2, FORWARD_LEN = 2)(input [ADDRESS_LEN-1:0] rd_addr_1_id_ex, input [ADDRESS_LEN-1:0] rd_addr_2_id_ex, input [ADDRESS_LEN-1:0] wr_addr_ex_mem, input [ADDRESS_LEN-1:0] wr_addr_mem_wb, input [CONTROL_LINE-1:0] control_ex_mem, input [CONTROL_LINE-1:0] control_mem_wb, output reg [FORWARD_LEN-1:0] forward_a, output reg [FORWARD_LEN-1:0] forward_b);

	wire ex_mem_reg_write;
	wire mem_wb_reg_write;
	
	assign ex_mem_reg_write = control_ex_mem[1];
	assign mem_wb_reg_write = control_mem_wb[1];
	
	always@*begin
		
		if((ex_mem_reg_write) && (wr_addr_ex_mem != 'b0) && (wr_addr_ex_mem == rd_addr_1_id_ex))begin
			forward_a = 2'b10;
		end
		else if((mem_wb_reg_write) && (wr_addr_mem_wb != 'b0) && (~((ex_mem_reg_write) && (wr_addr_ex_mem != 'b0) && (wr_addr_ex_mem == rd_addr_1_id_ex))) &&
					(wr_addr_mem_wb == rd_addr_1_id_ex)) begin
			forward_a = 2'b01;
		end
		else begin
			forward_a = 2'b00;
		end
	end
	
	always@*begin
		
		if((ex_mem_reg_write) && (wr_addr_ex_mem != 'b0) && (wr_addr_ex_mem == rd_addr_2_id_ex))begin
			forward_b = 2'b10;
		end
		else if((mem_wb_reg_write) && (wr_addr_mem_wb != 'b0) && (~((ex_mem_reg_write) && (wr_addr_ex_mem != 'b0) && (wr_addr_ex_mem == rd_addr_2_id_ex))) &&
					(wr_addr_mem_wb == rd_addr_2_id_ex)) begin
			forward_b = 2'b01;
		end
		else begin
			forward_b = 2'b00;
		end
	end		
	
endmodule