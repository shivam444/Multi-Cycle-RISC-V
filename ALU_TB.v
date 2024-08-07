module ALU_TB;
	
	localparam iterations = 100;
	reg [1:0] alu_op;
	reg [63:0] data_1;
	reg [63:0] data_2;
	wire [63:0] data_out;
	reg [63:0] data_out_exp;
	integer i;
	integer success;
	
	ALU alu_dut(.alu_op(alu_op),.data_1(data_1),.data_2(data_2),.data_out(data_out));
	
	initial begin
	    success = 0;
		data_1 = $random;
		data_2 = $random;
		for(i=0;i<iterations;i= i+1)begin
			alu_op = $random%4;
			case(alu_op)
				2'b00: data_out_exp = data_1 + data_2;
				2'b01: data_out_exp = data_1 - data_2;
				2'b10: data_out_exp = data_1 | data_2;
				2'b11: data_out_exp = data_1 & data_2;
				default: data_out_exp = 'b0;
			endcase
			#1
			if(data_out ^ data_out_exp == 'b0)begin
				success = success + 1;
			end
			else begin
				$display("ALU operation", alu_op);
			end
			#5;
		end
		$display("Success = %d / %d Passed", success, iterations);
	end
endmodule
			