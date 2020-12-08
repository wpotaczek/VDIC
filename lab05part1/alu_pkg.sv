/******************************************************************************
* (C) Copyright 2013 <Company Name> All Rights Reserved
*
* MODULE:    name
* DEVICE:
* PROJECT:
* AUTHOR:    wpotaczek
* DATE:      2020 4:25:45 PM
*
* ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
*
*******************************************************************************/

`timescale 1ns/1ps

package alu_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	typedef enum bit[2:0]  {and_op  		= 3'b000,
									or_op   		= 3'b001,
       							add_op   	= 3'b100,
       							sub_op   	= 3'b101,
              					er_data_op	= 3'b010,
       							er_crc_op  	= 3'b011,
       							er_op_op  	= 3'b110,
       							rst_op		= 3'b111} operation_t;
   
   typedef struct packed {
	   bit [31:0] A;
	   bit [31:0] B;
	   operation_t op;
   } command_s;
   
	localparam  DATA_TYPE = 1'b0,
     				CMD_TYPE = 1'b1,
     				ERR_DATA_FRAME = 8'b11001001,
     				ERR_CRC_FRAME = 8'b10100101,
     				ERR_OP_FRAME = 8'b10010011;
	
	`include "coverage.svh"
	`include "base_tester.svh"
	`include "random_tester.svh"
	`include "min_max_tester.svh"
	`include "scoreboard.svh"
	`include "driver.svh"	
	`include "command_monitor.svh"	
	`include "result_monitor.svh"	
	`include "env.svh"
	`include "random_test.svh"
	`include "min_max_test.svh"

endpackage : alu_pkg