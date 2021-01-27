/******************************************************************************
* DVT CODE TEMPLATE: package
* Created by wpotaczek on Jan 22, 2021
* uvc_company = wp, uvc_name = alu
*******************************************************************************/

package wp_alu_pkg;

	typedef enum bit[2:0]  {and_op  		= 3'b000,
									or_op   		= 3'b001,
       							add_op   	= 3'b100,
       							sub_op   	= 3'b101,
              					er_data_op	= 3'b010,
       							er_crc_op  	= 3'b011,
       							er_op_op  	= 3'b110,
       							rst_op		= 3'b111} operation_t;

	localparam  DATA_TYPE = 1'b0,
     				CMD_TYPE = 1'b1,
     				ERR_DATA_FRAME = 8'b11001001,
     				ERR_CRC_FRAME = 8'b10100101,
     				ERR_OP_FRAME = 8'b10010011;
	
	// UVM macros
	`include "uvm_macros.svh"
	// UVM class library compiled in a package
	import uvm_pkg::*;

	// Configuration object
	`include "wp_alu_config_obj.svh"
	// Sequence item
	`include "wp_alu_item.svh"
	// Monitor
	`include "wp_alu_monitor.svh"
	`include "wp_alu_result_monitor.svh"
	// Coverage Collector
	`include "wp_alu_coverage_collector.svh"
	//Scoreboard
	`include "wp_alu_scoreboard.svh"
	// Driver
	`include "wp_alu_driver.svh"
	// Sequencer
	`include "wp_alu_sequencer.svh"
	// Agent
	`include "wp_alu_agent.svh"
	// Environment
	`include "wp_alu_env.svh"
	// Sequence library
	`include "wp_alu_seq_lib.svh"
	//Base test
	`include "wp_alu_base_test.svh"
	//Example test
	`include "wp_alu_example_test.svh"
	//Tests	
	`include "wp_alu_random_test.svh"	
	`include "wp_alu_minmax_test.svh"

endpackage : wp_alu_pkg
