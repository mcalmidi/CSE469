// Akhila Narayanan and Manasvini Calmidi
// 4/4/2024
// CSE 469
// Lab #1, Task 3

// alu_testbench tests all the cases outlined in the lab spec. Specifically, the cases outlined in the table
// Those test vectors were written into a file called alu.tv and read here using readmemh

module alu_testbench();
	logic [31:0] a, b;
	logic [1:0] ALUControl;
	logic [31:0] Result;
	logic [3:0] ALUFlags;
	logic clk;
	logic [103:0] testvectors [1000:0]; // why 103?
	
	alu dut(.a, .b, .ALUControl, .Result, .ALUFlags);
	
	parameter CLOCK_PERIOD = 100;
	
	initial clk = 1;
	always begin
		#(CLOCK_PERIOD/2);
		clk = ~clk;
	end
	
	initial begin
		$readmemh("alu.tv", testvectors);
		
		for (int i = 0; i < 20; i++) begin
			{ALUControl, a, b, Result, ALUFlags} = testvectors[i]; @(posedge clk);
		end
	end
endmodule // alu_testbench