/******************************************************************************
* (C) Copyright 2013 <Company Name> All Rights Reserved
*
* MODULE:    dummy_dut
* DEVICE:
* PROJECT:
* AUTHOR:    wpotaczek
* DATE:      2021 12:20:17 AM
*
* ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
*
*******************************************************************************/

module dummy_dut(
	input wire clock,
	input wire reset,
	input wire valid,
	output logic [7:0] data
);
	
	assign data = '1;
	
endmodule
