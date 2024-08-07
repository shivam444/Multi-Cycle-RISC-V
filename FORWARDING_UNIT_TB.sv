`timescale 1ns/1ps

module FORWARDING_UNIT_TB;

	localparam ADDRESS_LEN = 5; 
	localparam CONTROL_LINE = 2; 
	localparam FORWARD_LEN = 2;
	
	localparam iter = 10000;
	
	logic [ADDRESS_LEN-1:0] rd_addr_1_id_ex; 
	logic [ADDRESS_LEN-1:0] rd_addr_2_id_ex; 
	logic [ADDRESS_LEN-1:0] wr_addr_ex_mem; 
	logic [ADDRESS_LEN-1:0] wr_addr_mem_wb; 
	logic [CONTROL_LINE-1:0] control_ex_mem; 
	logic [CONTROL_LINE-1:0] control_mem_wb; 
	logic [FORWARD_LEN-1:0] forward_a; 
	logic [FORWARD_LEN-1:0] forward_b;
	
	logic [FORWARD_LEN-1:0] forward_a_exp; 
	logic [FORWARD_LEN-1:0] forward_b_exp;
	
	int i;
	
	FORWARDING_UNIT#(.ADDRESS_LEN(ADDRESS_LEN),
						.CONTROL_LINE(CONTROL_LINE),
						.FORWARD_LEN(FORWARD_LEN))
						
					forwarding_unit_dut(.*);
			

	initial begin
		#100
		check;
		#10
		print;
		#10
		$finish;
	end
			
	task check;
		repeat(iter)begin
			rd_addr_1_id_ex = $urandom;
			rd_addr_2_id_ex = $urandom;
			wr_addr_ex_mem = $urandom;
			wr_addr_mem_wb = $urandom;
			control_ex_mem = $urandom;
			control_mem_wb = $urandom;
			
			if((control_ex_mem[1]) && (wr_addr_ex_mem != 'b0) && (wr_addr_ex_mem == rd_addr_1_id_ex))begin
				forward_a_exp = 2'b10;
			end
			else if((control_mem_wb[1]) && (wr_addr_mem_wb != 'b0) && (~((control_ex_mem[1]) && (wr_addr_ex_mem != 'b0) && (wr_addr_ex_mem == rd_addr_1_id_ex))) &&
						(wr_addr_mem_wb == rd_addr_1_id_ex)) begin
				forward_a_exp = 2'b01;
			end
			else begin
				forward_a_exp = 2'b00;
			end
			
			if((control_ex_mem[1]) && (wr_addr_ex_mem != 'b0) && (wr_addr_ex_mem == rd_addr_2_id_ex))begin
				forward_b_exp = 2'b10;
			end
			else if((control_mem_wb[1]) && (wr_addr_mem_wb != 'b0) && (~((control_ex_mem[1]) && (wr_addr_ex_mem != 'b0) && (wr_addr_ex_mem == rd_addr_2_id_ex))) &&
						(wr_addr_mem_wb == rd_addr_2_id_ex)) begin
				forward_b_exp = 2'b01;
			end
			else begin
				forward_b_exp = 2'b00;
			end
			
			#5
			if((forward_a == forward_a_exp) && (forward_b == forward_b_exp))begin
				i++;
			end
			else begin
				$display("%d,th iteration failed", i);
			end
		end
	endtask
	
	task print;
		if(i == iter)begin
			$display("Success, passed = %d/%d",i,iter);
		end
		else begin
			$display("Failed, passed = %d/%d",i,iter);
		end
	endtask
	
endmodule