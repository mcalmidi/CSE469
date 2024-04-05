module alu (a, b, ALUControl, Result, ALUFlags);
	input logic [31:0] a, b;
	input logic [1:0] ALUControl;
	output logic [31:0] Result;
	output logic [3:0] ALUFlags;
	
	// Add (not combinational)
	logic cin;
	logic [31:0] couts, bout, tb, addRes;
	assign tb = ~b + 1'b1;
	fullAdder m_add_0(.A(a[0]), .B(bout[0]), .cin(1'b0), .sum(addRes[0]), .cout(couts[0]));
	genvar i;
	generate 
		for (i = 1; i < 32; i++) begin : add
			fullAdder m_add(.A(a[i]), .B(bout[i]), .cin(couts[i-1]), .sum(addRes[i]), .cout(couts[i]));
		end
	endgenerate
	
	always_comb begin
		// Set bout to two's complement if we are subtracting
		if (ALUControl[0] == 1'b0) bout = b;
		else bout = tb;
		
		// And
		if (ALUControl == 2'b10) Result = a & b;
		
		// Or
		else if (ALUControl == 2'b11) Result = a | b;
		
		// Add/Subtract
		else Result = addRes;
		
		// Flags
		
		// Negative
		ALUFlags[3] = Result[31];
		
		// Zero
		ALUFlags[2] = (Result == 0);
		
		// Carry
		ALUFlags[1] = couts[31] & ~ALUControl[1];
		
		// Overflow
		ALUFlags[0] = ~ALUControl[1] & (Result[31] ^ a[31]) & ~(ALUControl[0] ^ a[31] ^ b[31]);
	end
endmodule // alu

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