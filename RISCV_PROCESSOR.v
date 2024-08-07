module RISCV_PROCESSOR#(parameter INSTRUCTION_ADDR_SIZE = 5, DATA_LEN = 64)(input clk, input rst, input ins_write,input [(2**INSTRUCTION_ADDR_SIZE)-1:0] instruction_in, output [DATA_LEN-1:0] res);
	
	localparam DATA_MEM_SIZE = 10;
	localparam INSTRUCTION_MEM_SIZE = 10;
	localparam R_FORMAT = 7'd51;
	localparam LOAD = 7'd3;
	localparam STORE = 7'd35;
	localparam BEQ = 7'd99;
	
	reg [INSTRUCTION_MEM_SIZE-1:0] wr_addr;
	reg [INSTRUCTION_MEM_SIZE-1:0] wr_addr_next;
	reg reg_write;
	reg alu_src;
	reg [1:0]alu_op;
	reg pc_src;
	reg mem_read;
	reg mem_write;
	reg mem_to_reg;
	wire [(2**INSTRUCTION_ADDR_SIZE)-1:0] instruction;
	wire [(2**INSTRUCTION_ADDR_SIZE)-1:0] instruction_ptr;
	reg [DATA_MEM_SIZE-1:0] data_mem_wr_addr;
	wire [DATA_LEN-1:0] rd_data_1;
	wire [DATA_LEN-1:0] rd_data_2;
	wire [DATA_LEN-1:0] rd_data_2_;
	wire [DATA_LEN-1:0] data_2;
	wire [DATA_LEN-1:0] data_out;
	wire [DATA_LEN-1:0] data_mem_data_out;
	reg [DATA_LEN-1:0] data_in;
	reg [11:0] offset_addr;
	
	assign rd_data_2_ = mem_to_reg?data_mem_data_out:data_out;
	assign data_2 = alu_src ? offset_addr : rd_data_2 ; 
	
	PROGRAM_COUNTER#(.ADDRESS_SIZE(INSTRUCTION_ADDR_SIZE),.N(DATA_LEN)) pc_dut(.clk(clk),.rst(rst),.ins_write(ins_write),.pc_src(pc_src),.offset_addr(offset_addr),.instruction_ptr(instruction_ptr));
	INSTRUCTION_MEMORY instruction_mem_dut(.clk(clk),.rst(rst),.ins_write(ins_write),.wr_addr(wr_addr),.instruction_in(instruction_in),.rd_addr(instruction_ptr),.instruction(instruction));
	REGISTER_FILE register_dut(.clk(clk),.rst(rst),.ins_write(ins_write),.reg_write(reg_write),.rd_addr_1(instruction[19:15]),.rd_addr_2(instruction[24:20]),.wr_addr(instruction[11:7]),.data(rd_data_2_),.rd_data_1(rd_data_1),.rd_data_2(rd_data_2));
	ALU#(.N(DATA_LEN)) alu_dut(.instruction(instruction),.alu_op(alu_op),.data_1(rd_data_1),.data_2(data_2),.data_out(data_out));
	DATA_MEMORY data_mem_dut(.clk(clk),.rst(rst),.mem_read(mem_read),.mem_write(mem_write),.rd_addr(data_out),.wr_addr(data_mem_wr_addr),.data_in(data_in),.data_out(data_mem_data_out));
	
	always@*begin
		data_mem_wr_addr = data_out;
		data_in = rd_data_2;
	end
	
	always@*begin
		case(instruction[6:0])
			BEQ : offset_addr = {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
			LOAD : offset_addr = instruction[31:20];
			STORE : offset_addr = {instruction[31:25] , instruction[11:7]};
			default : offset_addr = 'b0;
		endcase
	end
	
	always@*begin
		case(instruction[6:0])
			R_FORMAT : begin
							alu_src = 1'b0;
							mem_to_reg = 1'b0;
							reg_write = 1'b1;
							mem_read = 1'b0;
							mem_write = 1'b0;
							pc_src = 1'b0;
							alu_op = 2'b10;
						end
			LOAD : begin
							alu_src = 1'b1;
							mem_to_reg = 1'b1;
							reg_write = 1'b1;
							mem_read = 1'b0;
							mem_write = 1'b0;
							pc_src = 1'b0;
							alu_op = 2'b00;
					end
			STORE : begin
							alu_src = 1'b1;
							mem_to_reg = 1'bx;
							reg_write = 1'b0;
							mem_read = 1'b0;
							mem_write = 1'b1;
							pc_src = 1'b0;
							alu_op = 2'b00;
					end
			BEQ : begin
							alu_src = 1'b0;
							mem_to_reg = 1'bx;
							reg_write = 1'b0;
							mem_read = 1'b0;
							mem_write = 1'b0;
							pc_src = 1'b1;
							alu_op = 2'b01;
				end
			default : begin
							alu_src = 1'b1;
							mem_to_reg = 1'b1;
							reg_write = 1'b1;
							mem_read = 1'b0;
							mem_write = 1'b0;
							pc_src = 1'b0;
							alu_op = 2'b00;
					end
		endcase
	end
	
	always@*begin
		wr_addr_next = wr_addr + 1'b1;
	end
	
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			wr_addr <= 'b0;
		end
		else if(ins_write)begin
			wr_addr <= wr_addr_next;
		end
	end
	
	assign res = ins_write?'b0:rd_data_2_;
	
endmodule	