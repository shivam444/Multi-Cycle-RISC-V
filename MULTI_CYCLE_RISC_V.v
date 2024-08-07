module MULTI_CYCLE_RISC_V#(parameter INSTRUCTION_ADDR_SIZE = 5, DATA_LEN = 64)(input clk, input rst, input ins_write,input [(2**INSTRUCTION_ADDR_SIZE)-1:0] instruction_in, output [DATA_LEN-1:0] res);

	localparam R_FORMAT = 7'd51;
	localparam LOAD = 7'd3;
	localparam STORE = 7'd35;
	localparam BEQ = 7'd99;
	
	localparam INSTRUCTION_MEMORY_SIZE = 10; //2**10
	localparam INSTRUCTION_LEN = 32;
	localparam IF_ID_PIPELINE_ADDRESS_SIZE = 6;
	localparam REGISTER_ADDRESS_LEN = 5;
	localparam ID_EX_CONTROL_LINE = 8;
	localparam INSTRUCTION_1_LEN = 10;
	localparam INSTRUCTION_2_LEN = 5;
	localparam EX_MEM_CONTROL_LINE = 5;
	localparam MEM_WB_CONTROL_LINE = 2;
	localparam DATA_MEMORY_SIZE = 5;
	
	wire [INSTRUCTION_LEN-1:0] instruction;
	wire [INSTRUCTION_LEN-1:0] if_id_instruction_out;
	wire [INSTRUCTION_LEN-1:0] id_ex_instruction_out;
	wire [(2**INSTRUCTION_ADDR_SIZE)-1:0] instruction_ptr;
	wire [(2**INSTRUCTION_ADDR_SIZE)-1:0] if_id_instruction_ptr_out;
	wire [(2**INSTRUCTION_ADDR_SIZE)-1:0] new_pc;
	wire [DATA_LEN-1:0] register_file_rd_data_1;
	wire [DATA_LEN-1:0] register_file_rd_data_2;
	wire [ID_EX_CONTROL_LINE-1:0] decode_control;
	wire [ID_EX_CONTROL_LINE-1:0] muxed_decode_control;
	wire pc_write;
	wire IF_ID_WRITE;
	wire decode_mux_sel;
	wire [INSTRUCTION_1_LEN-1:0] instruction_part_1_out;
	wire [INSTRUCTION_2_LEN-1:0] instruction_part_2_out;
	wire [ID_EX_CONTROL_LINE-1:0] id_ex_control_out;
	wire [DATA_LEN-1:0] id_ex_data_1;
	wire [DATA_LEN-1:0] id_ex_data_2;
	wire [(2**INSTRUCTION_ADDR_SIZE)-1:0] id_ex_instruction_ptr_out;
	wire [DATA_LEN-1:0] id_ex_imm_val_out;
	wire [INSTRUCTION_1_LEN-1:0] id_ex_instruction_part_1;
	wire [INSTRUCTION_2_LEN-1:0] id_ex_instruction_part_2;
	wire [DATA_LEN-1:0] ex_mem_alu_res;
	wire [DATA_LEN-1:0] mem_wb_mux_out;
	wire [REGISTER_ADDRESS_LEN-1:0] id_ex_rd_addr_1;
	wire [REGISTER_ADDRESS_LEN-1:0] id_ex_rd_addr_2;
	wire [REGISTER_ADDRESS_LEN-1:0] ex_mem_wr_addr;
	wire [REGISTER_ADDRESS_LEN-1:0] mem_wb_wr_addr;
	wire [1:0] ex_mem_control;
	wire [1:0] mem_wb_control;
	wire [1:0] forward_a;
	wire [1:0] forward_b;
	wire [DATA_LEN-1:0] alu_out;
	wire [EX_MEM_CONTROL_LINE-1:0] ex_mem_comtrol_out;
	wire ex_mem_zero_out;
	wire [DATA_LEN-1:0] ex_mem_alu_val_out;
	wire [DATA_LEN-1:0] ex_mem_wr_data_out;
	wire [INSTRUCTION_2_LEN-1:0] ex_mem_instruction_part_out;
	wire [DATA_LEN-1:0] mem_data_out;
	wire [MEM_WB_CONTROL_LINE-1:0] mem_wb_control_out;
	wire [DATA_LEN-1:0] mem_wb_rd_data_out;
	wire [DATA_LEN-1:0] mem_wb_addr_out;
	wire [INSTRUCTION_2_LEN-1:0] mem_wb_instruction_part_out;
	wire [DATA_LEN-1:0] register_file_data_in;
	wire reg_write;
	wire mem_pc_src;
	wire predictor_pc_src;
	wire pc_src;
	wire if_beq;
	wire id_ex_predictor_out;
	wire ex_mem_predictor_out;
	wire ID_FLUSH;
	wire EX_FLUSH;
	wire id_ex_if_beq;
	wire ex_mem_if_beq;
	wire branch_src;
	wire IF_FLUSH;
	
	reg [INSTRUCTION_MEMORY_SIZE-1:0] instruction_mem_wr_addr;
	reg [11:0] offset_addr;
	reg [REGISTER_ADDRESS_LEN-1:0] id_ex_wr_addr;
	reg id_ex_mem_read;
	reg [DATA_LEN-1:0] alu_in_1;
	reg [DATA_LEN-1:0] alu_in_2;
	
	//FETCH STAGE
	
	//assign pc_src = predictor_pc_src;
	
	PROGRAM_COUNTER#(.ADDRESS_SIZE(INSTRUCTION_ADDR_SIZE),.N(DATA_LEN))
					program_counter(.clk(clk),.rst(rst),.ins_write(ins_write),.pc_write(pc_write),.pc_src(pc_src),
					.new_pc(new_pc),.instruction_ptr(instruction_ptr));
					
	INSTRUCTION_MEMORY#(.ADDRESS_SIZE(INSTRUCTION_MEMORY_SIZE),.N(INSTRUCTION_LEN))
					instruction_memory(.clk(clk),.rst(rst),.ins_write(ins_write),.wr_addr(instruction_mem_wr_addr),
					.instruction_in(instruction_in),.rd_addr(instruction_ptr),.instruction(instruction));
					
	always@(posedge clk or negedge rst)begin
		if(~rst)begin
			instruction_mem_wr_addr <= 'b0;
		end
		else if(ins_write) begin
			instruction_mem_wr_addr <= instruction_mem_wr_addr + 1'b1;
		end
	end
					
	//TILL HERE FETCH STAGE
	
	//FETCH DECODE PIPELINE				
	IF_ID_PIPELINE#(.INSTRUCTION_LEN(INSTRUCTION_LEN),.ADDRESS_SIZE(IF_ID_PIPELINE_ADDRESS_SIZE))
					if_id_pipeline(.clk(clk),.rst(rst),.instruction_in(instruction),.instruction_ptr_in(instruction_ptr),
					.IF_FLUSH(IF_FLUSH),.IF_ID_WRITE(IF_ID_WRITE),.instruction_out(if_id_instruction_out),
					.instruction_ptr_out(if_id_instruction_ptr_out));
	//
	
	//DECODE STAGE				
	REGISTER_FILE#(.ADDRESS_LEN(REGISTER_ADDRESS_LEN), .N(DATA_LEN)) 
					register_file_dut(.clk(clk),.rst(rst),.ins_write(ins_write),.reg_write(reg_write),
					.rd_addr_1(if_id_instruction_out[19:15]),.rd_addr_2(if_id_instruction_out[24:20]),
					.wr_addr(if_id_instruction_out[11:7]),.data(register_file_data_in),.rd_data_1(register_file_rd_data_1),
					.rd_data_2(register_file_rd_data_2));
					
	CONTROL_UNIT#(.INSTRUCTION_LEN(INSTRUCTION_LEN),.CONTROL_LINE(ID_EX_CONTROL_LINE))
					control_unit(.instruction(if_id_instruction_out),.control(decode_control));
					
	HAZARD_DETECTION_UNIT#(.ADDRESS_LEN(INSTRUCTION_1_LEN/2))
					hazard_detection_unit(.rd_addr_1_if_id(if_id_instruction_out[19:15]),.rd_addr_2_if_id(if_id_instruction_out[24:20]),
					.wr_addr_id_ex(id_ex_wr_addr),.mem_read_id_ex(id_ex_wr_addr),.pc_write(pc_write),
					.if_id_write(IF_ID_WRITE),.mux_sel(decode_mux_sel));
				
	assign if_beq = (if_id_instruction_out[6:0] == BEQ)?1'b1:1'b0;
	
	//Predictor
	PREDICTOR predictor_dut(.clk(clk),.rst(rst),.ex_mem_if_beq(ex_mem_if_beq), .if_beq(if_beq),.taken(mem_pc_src),.take_status(predictor_pc_src));
	
	assign pc_src = if_beq?(branch_src?ex_mem_zero_out:predictor_pc_src):'b0;
	
	//
			
	always@*begin
		case(if_id_instruction_out[6:0])
			BEQ : offset_addr = {if_id_instruction_out[31], if_id_instruction_out[7], if_id_instruction_out[30:25], if_id_instruction_out[11:8]};
			LOAD : offset_addr = if_id_instruction_out[31:20];
			STORE : offset_addr = {if_id_instruction_out[31:25] , if_id_instruction_out[11:7]};
			default : offset_addr = 'b0;
		endcase
	end
	
	assign new_pc = if_id_instruction_ptr_out + (offset_addr<<1);
	assign muxed_decode_control = decode_mux_sel?decode_control:'b0;
	
	//TILL HERE DECODE STAGE
	
	//DECODE EXECUTE PIPELINE
	
	ID_EX_PIPELINE#(.DATA_LEN(DATA_LEN),.CONTROL_LINE_IN(ID_EX_CONTROL_LINE),.CONTROL_LINE_OUT(ID_EX_CONTROL_LINE),
					.ADDRESS_SIZE(IF_ID_PIPELINE_ADDRESS_SIZE), .INSTRUCTION_1_LEN(INSTRUCTION_1_LEN), 
					.INSTRUCTION_2_LEN(INSTRUCTION_2_LEN), .INSTRUCTION_LEN(INSTRUCTION_LEN))
					id_ex_pipeline(.clk(clk),.rst(rst),.ID_FLUSH(ID_FLUSH),.if_beq(if_beq),.data_1(register_file_rd_data_1),
					.data_2(register_file_rd_data_2),.imm_val({'b0,offset_addr}),.control_in(muxed_decode_control),
					.instruction_ptr_in(if_id_instruction_ptr_out),.instruction_part_1(if_id_instruction_out[24:15]),
					.instruction_part_2(if_id_instruction_out[11:7]), .instruction_in(if_id_instruction_out), 
					.predictor_val(predictor_pc_src), .control_out(id_ex_control_out),.data_1_out(id_ex_data_1),
					.data_2_out(id_ex_data_2),.instruction_ptr_out(id_ex_instruction_ptr_out),.imm_val_out(id_ex_imm_val_out),
					.instruction_part_1_out(id_ex_instruction_part_1),.instruction_part_2_out(id_ex_instruction_part_2),
					.instruction_out(id_ex_instruction_out), .predictor_out(id_ex_predictor_out),.if_beq_out(id_ex_if_beq));
	//
					
	//EXECUTE STAGE
	
	always@*begin
		case(forward_a)
			2'b00: alu_in_1 = id_ex_data_1;
			2'b01: alu_in_1 = ex_mem_alu_res;
			2'b10: alu_in_1 = mem_wb_mux_out;
			default: alu_in_1 = id_ex_data_1;
		endcase
		
		case(forward_b)
			2'b00: alu_in_2 = id_ex_data_2;
			2'b01: alu_in_2 = ex_mem_alu_res;
			2'b10: alu_in_2 = mem_wb_mux_out;
			default: alu_in_2 = id_ex_data_2;
		endcase
	end
	
	assign id_ex_rd_addr_1 = id_ex_instruction_part_1[9:5];
	assign id_ex_rd_addr_2 = id_ex_instruction_part_1[4:0];
	assign ex_mem_wr_addr = ex_mem_instruction_part_out;
	assign ex_mem_control = ex_mem_comtrol_out;
	assign mem_wb_control = mem_wb_control_out;
	assign mem_wb_wr_addr = mem_wb_instruction_part_out;
	
	FORWARDING_UNIT#(.ADDRESS_LEN(REGISTER_ADDRESS_LEN),.CONTROL_LINE(2),.FORWARD_LEN(2))
					forward_unit(.rd_addr_1_id_ex(id_ex_rd_addr_1), .rd_addr_2_id_ex(id_ex_rd_addr_2), .wr_addr_ex_mem(ex_mem_wr_addr),
					.wr_addr_mem_wb(mem_wb_wr_addr),.control_ex_mem(ex_mem_control),.control_mem_wb(mem_wb_control),.forward_a(forward_a),.forward_b(forward_b));
					
	
	ALU#(.INSTRUCTION_LEN(INSTRUCTION_LEN), .N(DATA_LEN))
		alu_dut(.instruction(id_ex_instruction_out), .alu_op(id_ex_control_out[7:6]), .data_1(alu_in_1),.data_2(id_ex_data_2),
		.data_out(alu_out));
	
	//TILL HERE EXECUTE STAGE
	
	//EXECUTE MEMORY PIPELINE
	
	EX_MEM_PIPELINE#(.CONTROL_LINE(EX_MEM_CONTROL_LINE), .DATA_LEN(DATA_LEN), .INSTRUCTION_PART(INSTRUCTION_2_LEN))
					ex_mem_pipeline(.clk(clk), .rst(rst),.EX_FLUSH(EX_FLUSH),.if_beq(id_ex_if_beq), .alu_val(alu_out), .wr_addr(alu_in_2), 
					.instruction_part(id_ex_instruction_part_2),.control_in(id_ex_control_out[EX_MEM_CONTROL_LINE-1:0]), 
					.zero_in(alu_out?1'b0:1'b1), .predictor_val(id_ex_predictor_out), .control_out(ex_mem_comtrol_out),
					.zero_out(ex_mem_zero_out), .alu_val_out(ex_mem_alu_val_out), .wr_addr_out(ex_mem_wr_data_out), 
					.instruction_part_out(ex_mem_instruction_part_out), .predictor_out(ex_mem_predictor_out), .if_beq_out(ex_mem_if_beq));
	
	//


	//MEMORY STAGE
	DATA_MEMORY#(.ADDRESS_SIZE(DATA_MEMORY_SIZE), .N(DATA_LEN))
				data_memory(.clk(clk), .rst(rst), .mem_read(ex_mem_comtrol_out[EX_MEM_CONTROL_LINE-2]), 
				.mem_write(ex_mem_comtrol_out[EX_MEM_CONTROL_LINE-3]), .rd_addr(ex_mem_alu_val_out), .wr_addr(ex_mem_alu_val_out),
				.data_in(ex_mem_wr_data_out), .data_out(mem_data_out));
				
	assign mem_pc_src = ex_mem_if_beq & ex_mem_zero_out;
	
	assign IF_FLUSH = ex_mem_if_beq?(ex_mem_predictor_out^ex_mem_zero_out):'b0;
	assign ID_FLUSH = ex_mem_if_beq?(ex_mem_predictor_out^ex_mem_zero_out):'b0;
	assign EX_FLUSH = ex_mem_if_beq?(ex_mem_predictor_out^ex_mem_zero_out):'b0;
	assign branch_src = ex_mem_if_beq?(ex_mem_predictor_out^ex_mem_zero_out):'b0;
	
	//TILL HER MEMORY STAGE
	
	//MEMORY WRITE-BACK PIPELINE
	
	MEM_WB_PIPELINE#(.DATA_LEN(DATA_LEN), .CONTROL_LINE(MEM_WB_CONTROL_LINE), .INSTRUCTION_PART(INSTRUCTION_2_LEN))
					mem_wb_pipeline(.clk(clk), .rst(rst), .rd_data(mem_data_out), .control_in(ex_mem_comtrol_out[MEM_WB_CONTROL_LINE-1:0]),
					.addr(ex_mem_alu_val_out), .instruction_part(ex_mem_instruction_part_out), .control_out(mem_wb_control_out),
					.rd_data_out(mem_wb_rd_data_out), .addr_out(mem_wb_addr_out), .instruction_part_out(mem_wb_instruction_part_out));
					
	//
	
	//
	assign register_file_data_in = mem_wb_control_out[0]?mem_wb_rd_data_out:mem_wb_addr_out;
	assign reg_write = mem_wb_control_out[1];
	
	//
	
	assign res = ins_write?'b0:register_file_data_in;
	
endmodule