/******************************************************************************
* DVT CODE TEMPLATE: testbench top module
* Created by wpotaczek on Jan 22, 2021
* uvc_company = wp, uvc_name = alu
*******************************************************************************/

module alu_tb_top;

	// Import the UVM package
	import uvm_pkg::*;

	// Import the UVC that we have implemented
	import wp_alu_pkg::*;

	// Import all the needed packages
	

	// Clock and reset signals
	reg clock;
	reg reset;

	// The interface
	wp_alu_if vif(clock,reset);

	// add other interfaces if needed

	// TODO instantiate the DUT
	dummy_dut dut(
		clock,
		reset,
		vif.valid,
		vif.data
	);

	initial begin
		// Propagate the interface to all the components that need it
		uvm_config_db#(virtual wp_alu_if)::set(uvm_root::get(), "*", "m_wp_alu_vif", vif);
		// Start the test
		run_test();
	end

	// Generate clock
	always
		#5 clock=~clock;

	// Generate reset
	initial begin
		reset <= 1'b1;
		clock <= 1'b1;
		#21 reset <= 1'b0;
		#51 reset <= 1'b1;
	end
endmodule
