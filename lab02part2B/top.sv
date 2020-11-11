/******************************************************************************
* (C) Copyright 2013 <Company Name> All Rights Reserved
*
* MODULE:    name
* DEVICE:
* PROJECT:
* AUTHOR:    wpotaczek
* DATE:      2020 4:14:58 PM
*
* ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
*
*******************************************************************************/

module top;
import alu_pkg::*
`include "alu_macros.svh";

	mtm_Alu DUT (
		.clk(bfm.clk),
		.rst_n(bfm.rst_n),
		.sin(bfm.sin),
		.sout(bfm.sout)
	);
	
	alu_bfm bfm();
	testbench testbench_h;
	
	initial begin
		testbench_h = new(bfm);
		testbench_h.execute();
	end
	
	final begin
		testbench_h.print_results();
	end	
	  
endmodule : top