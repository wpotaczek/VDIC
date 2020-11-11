/******************************************************************************
* (C) Copyright 2013 <Company Name> All Rights Reserved
*
* MODULE:    name
* DEVICE:
* PROJECT:
* AUTHOR:    wpotaczek
* DATE:      2020 6:17:05 PM
*
* ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
*
*******************************************************************************/

class testbench;
	
	virtual alu_bfm bfm;
	
	function new(virtual alu_bfm b);
		bfm = b;
	endfunction :new
	
	tester tester_h;
	coverage coverage_h;
	scoreboard scoreboard_h;
	
	task execute();
		tester_h = new(bfm);
		coverage_h = new(bfm);
		scoreboard_h = new(bfm);
		
		fork
			tester_h.execute();
			coverage_h.execute();
			scoreboard_h.execute();
		join_none
	endtask : execute
	
	function void print_results();
		scoreboard_h.print_results();
	endfunction
	
endclass :testbench