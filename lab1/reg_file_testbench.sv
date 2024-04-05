// Akhila Narayanan and Manasvini Calmidi
// 4/4/2024
// CSE 469
// Lab #1, Task 2

// reg_file_testbench tests all the cases outlined in the lab spec
// 1. Write data is written into the register file the clock cycle after wr_en is asserted.
// 2. Read data is updated to the register data at an address the same cycle the address was
// 	provided. Do this for both read addresses and data outputs.
// 3. Read data is updated to write data at an address the cycle after the address was provided
// 	if the write address is the same and wr_en was asserted. Do this for both read addresses
// 	and data outputs.

// The comments on the RHS of the test cases explain what the expected values of the outputs should be

module reg_file_testbench();
	logic clk, wr_en;
	logic [31:0] write_data, read_data1, read_data2;
	logic [3:0] write_addr, read_addr1, read_addr2;
	
	reg_file dut(.clk, .wr_en, .write_data, .write_addr, .read_addr1, .read_addr2, .read_data1, .read_data2);
	
	// Set up the clock
   parameter CLOCK_PERIOD=100;
   initial begin
     clk <= 0;
     forever #(CLOCK_PERIOD/2) clk <= ~clk;
   end
	
	initial begin
		wr_en <= 0; write_data <= 1; write_addr <= 0; read_addr1 <= 0; read_addr2 <= 1; @(posedge clk); // read_data1 = x, read_data2 = x because first time
		wr_en <= 0; write_data <= 1; write_addr <= 0; read_addr1 <= 0; read_addr2 <= 1; @(posedge clk); // read_data1 = x, read_data2 = x because wr_en = 0
		wr_en <= 1; write_data <= 1; write_addr <= 0; read_addr1 <= 0; read_addr2 <= 1; @(posedge clk); // read_data1 = x, read_data2 = x because 1 more clk cycle for wr_en
		wr_en <= 1; write_data <= 2; write_addr <= 1; read_addr1 <= 0; read_addr2 <= 0; @(posedge clk); // read_data1 = 1, read_data2 = x 

		wr_en <= 1; write_data <= 3; write_addr <= 2; read_addr1 <= 0; read_addr2 <= 1; @(posedge clk); // read_data1 = 1, read_data2 = 2
		wr_en <= 1; write_data <= 1; write_addr <= 0; read_addr1 <= 2; read_addr2 <= 0; @(posedge clk); // read_data1 = 3, read_data2 = 1

		wr_en <= 1; write_data <= 4; write_addr <= 3; read_addr1 <= 3; read_addr2 <= 0; @(posedge clk); // read_data1 = x, read_data2 = 1
		wr_en <= 1; write_data <= 5; write_addr <= 4; read_addr1 <= 3; read_addr2 <= 4; @(posedge clk); // read_data1 = 4, read_data2 = x
		wr_en <= 1; write_data <= 1; write_addr <= 0; read_addr1 <= 3; read_addr2 <= 4; @(posedge clk); // read_data1 = 4, read_data2 = 5
		$stop;
	end
endmodule 