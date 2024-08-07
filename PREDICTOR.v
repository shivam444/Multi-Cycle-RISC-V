module PREDICTOR(input clk, input rst, input ex_mem_if_beq, input if_beq, input taken, output reg take_status);
	
	localparam TAKEN_0 = 2'b00;
	localparam TAKEN_1 = 2'b01;
	localparam NOT_TAKEN_0 = 2'b10;
	localparam NOT_TAKEN_1 = 2'b11;
	
	reg [1:0] present_state;
	reg [1:0] next_state;
	
	always@*begin
		if(ex_mem_if_beq)begin
			case(present_state)
				TAKEN_0: begin
							if(taken)begin
								next_state = TAKEN_0;
							end
							else begin
								next_state = TAKEN_1;
							end
						end
				TAKEN_1: begin
							if(taken)begin
								next_state = TAKEN_0;
							end
							else begin
								next_state = NOT_TAKEN_0;
							end
						end
				NOT_TAKEN_0: begin
								if(taken)begin
									next_state = TAKEN_1;
								end
								else begin
									next_state = NOT_TAKEN_1;
								end
							end
				NOT_TAKEN_1: begin
								if(taken)begin
									next_state = NOT_TAKEN_0;
								end
								else begin
									next_state = NOT_TAKEN_1;
								end
							end
				default: next_state = present_state;
			endcase
		end
		else begin
			next_state = present_state;
		end
	end
	
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			present_state <= TAKEN_1;
		end
		else begin
			present_state <= next_state;
		end
	end
	
	always@*begin
		if(((present_state == 2'b00) || (present_state == 2'b01)) && if_beq)begin
			take_status = 1'b1;
		end
		else begin
			take_status = 1'b0;
		end
	end
	
endmodule
					