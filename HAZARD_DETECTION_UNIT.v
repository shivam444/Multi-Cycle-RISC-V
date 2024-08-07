module HAZARD_DETECTION_UNIT#(parameter ADDRESS_LEN = 5)(input [ADDRESS_LEN-1:0] rd_addr_1_if_id, input [ADDRESS_LEN-1:0] rd_addr_2_if_id, input [ADDRESS_LEN-1:0] wr_addr_id_ex, input mem_read_id_ex, output reg pc_write, output reg if_id_write, output reg mux_sel);

	always@*begin
		if((mem_read_id_ex) && ((wr_addr_id_ex == rd_addr_1_if_id) || (wr_addr_id_ex == rd_addr_2_if_id)))begin
			pc_write = 1'b0;
			if_id_write = 1'b0;
			mux_sel = 1'b0;
		end
		else begin
			pc_write = 1'b1;
			if_id_write = 1'b1;
			mux_sel = 1'b1;
		end
	end
endmodule