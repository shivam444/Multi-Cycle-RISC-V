`timescale 1ns/1ps

module HAZARD_DETECTION_UNIT_TB;

	localparam ADDRESS_LEN = 5;
	localparam iter = 10000;
	
	logic [ADDRESS_LEN-1:0] rd_addr_1_if_id; 
	logic [ADDRESS_LEN-1:0] rd_addr_2_if_id; 
	logic [ADDRESS_LEN-1:0] wr_addr_id_ex; 
	logic mem_read_id_ex; 
	logic pc_write; 
	logic if_id_write; 
	logic mux_sel;
	
	logic pc_write_exp; 
	logic if_id_write_exp; 
	logic mux_sel_exp;
	
	int i;
	
	HAZARD_DETECTION_UNIT#(.ADDRESS_LEN(ADDRESS_LEN))
						
						hazard_detection_unit_dut(.*);
						
	initial  begin
		#100
		check;
		#10
		print;
		#10
		$finish;
	end
	
	task check;
		repeat(iter)begin
			rd_addr_1_if_id = $urandom;
			rd_addr_2_if_id = $urandom;
			wr_addr_id_ex = $urandom;
			mem_read_id_ex = $urandom;
			
			if((mem_read_id_ex) && ((wr_addr_id_ex == rd_addr_1_if_id) || (wr_addr_id_ex == rd_addr_2_if_id)))begin
				pc_write_exp = 1'b0;
				if_id_write_exp = 1'b0;
				mux_sel_exp = 1'b0;
			end
			else begin
				pc_write_exp = 1'b1;
				if_id_write_exp = 1'b1;
				mux_sel_exp = 1'b1;
			end
			
			#5
			
			if((pc_write == pc_write_exp) && (if_id_write == if_id_write_exp) && (mux_sel == mux_sel_exp))begin
				i++;
			end
			else begin
				$display("%dth iteration failed", i);
			end
		end
	endtask;
	
	task print;
		if(i == iter)begin
			$display("Succes, passed = %d/%d", i, iter);
		end
		else begin
			$display("Succes, passed = %d/%d", i, iter);
		end
	endtask

endmodule
			
	
	