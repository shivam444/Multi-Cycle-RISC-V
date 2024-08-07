module datamem_tb;
bit clk; always #5 clk++;
bit rst; initial #1 rst ='b1; 
parameter ADDRESS_SIZE = 10, N = 64;
logic mem_read ;
logic mem_write; 
logic [ADDRESS_SIZE - 1:0] rd_addr; 
logic [ADDRESS_SIZE-1:0] wr_addr;
logic [N-1:0] data_in; 
logic [N-1:0] data_out; //output
int k,j,l ;

DATA_MEMORY dut (.*);


//stimulus generatiopn thread 

initial begin 
@(posedge clk);
//sc1;
$display("\n ****************END OF first SC1***************");
repeat(2) @(posedge clk);
//sc2;
$display("\n ****************END OF SC2***************");
repeat(2) @(posedge clk);
//sc1;
$display("\n ****************END OF second SC1***************");
repeat(2) @(posedge clk);
sc4;
$display("\n ****************END OF SC3***************");
repeat(2) @(posedge clk);
$display("\n ****************END OF SIMULATION***************");
$finish;
end 


task sc1;
mem_write = 1;
repeat(20) begin
	@(posedge clk);
	wr_addr = $urandom_range(100,150);
	data_in = $urandom_range(50000,80000);
	++k;
	$display("[%0t ns] :: %0d th Iteration :: mem_write = %0b, wr_addr =%0h, data_in =%0h",$time,k,mem_write,wr_addr,data_in);
end
mem_write = 0;
endtask 


task sc2;
mem_read = 1;
repeat(20) begin
	@(posedge clk);
	rd_addr = $urandom_range(100,150);
	++j;
	$display("%[%0t ns] :: %0d th Iteration :: mem_read = %0b, rd_addr =%0h, data_out =%0h",$time, j,mem_read,rd_addr,data_out);
end
mem_read = 0;
endtask

task sc3;
repeat(40) begin
	@(posedge clk);
	{mem_write,mem_read} = $urandom_range(1,2);
	++l;
	if(mem_write)  begin 
	wr_addr = $urandom_range(100,130);
	data_in = $urandom_range(80000,90000);
		$display("[%0t ns] :: %0d th Iteration :: mem_write = %0b, wr_addr =%0h, data_in =%0h",$time,l,mem_write,wr_addr,data_in);
	end 
	else begin
	rd_addr = $urandom_range(100,130);
		$display("%[%0t ns] :: %0d th Iteration :: mem_read = %0b, rd_addr =%0h, data_out =%0h",$time, l,mem_read,rd_addr,data_out);
	end 
end
endtask

task sc4;
repeat(20) begin
	@(posedge clk);
	++l;
	{mem_write,mem_read} = 2'b10;
	wr_addr = $urandom_range(100,130);
	data_in = $urandom_range(80000,90000);
	$display("[%0t ns] :: %0d th Iteration :: mem_write = %0b, wr_addr =%0h, data_in =%0h",$time,l,mem_write,wr_addr,data_in);
	
	@(posedge clk);
	@(posedge clk);
	++l;
	{mem_write,mem_read} = 2'b01;
	rd_addr = wr_addr ;
	$display("%[%0t ns] :: %0d th Iteration :: mem_read = %0b, rd_addr =%0h, data_out =%0h",$time, l,mem_read,rd_addr,data_out); 
end
endtask

endmodule 