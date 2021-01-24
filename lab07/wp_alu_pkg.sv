/******************************************************************************
* DVT CODE TEMPLATE: package
* Created by wpotaczek on Jan 22, 2021
* uvc_company = wp, uvc_name = alu
*******************************************************************************/

package wp_alu_pkg;

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
	// Coverage Collector
	`include "wp_alu_coverage_collector.svh"
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

endpackage : wp_alu_pkg
