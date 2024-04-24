// Akhila Narayanan and Manasvini Calmidi
// 4/4/2024
// CSE 469
// Lab #1, Task 2

// reg_file takes 1-bit clk and wr_en, 32-bit write_data, and 4-bit write_addr, 
// read_addr1, and read_addr2 as inputs and returns 32-bit read_data1 and read_addr2
// as outputs. read_data1 and read_data2 are driven by an intermediate array called
// "memory". At each positive edge of the clock cycle, we write the current value of 
// write_data to "memory" at index = current value of write_addr. Whatever is written 
// at indexes read_addr1 and read_addr2 will be outputted in read_data1 and read_data2.

module reg_file(clk, wr_en, write_data, write_addr, read_addr1, read_addr2, read_data1, read_data2);
	input logic clk, wr_en;
	input logic [31:0] write_data;
	input [3:0] write_addr, read_addr1, read_addr2;
	output logic [31:0] read_data1, read_data2;
	
	logic [15:0][31:0] memory;
	
	// writing the current value of write_data at the index of
	// the current value of write_addr in the array called memory
	always_ff @(posedge clk) begin
		if (wr_en) begin
			memory[write_addr] <= write_data;
		end
	end
	
	// read_data1 and read_data2 are driven off.
	assign read_data1 = memory[read_addr1];
	assign read_data2 = memory[read_addr2];
endmodule