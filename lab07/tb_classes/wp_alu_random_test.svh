/******************************************************************************
* DVT CODE TEMPLATE: example test
* Created by wpotaczek on Jan 25, 2021
* uvc_company = wp, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_wp_alu_random_test
`define IFNDEF_GUARD_wp_alu_random_test

class  wp_alu_random_test extends wp_alu_base_test;

	`uvm_component_utils(wp_alu_random_test)

	function new(string name = "wp_alu_random_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		uvm_config_db#(uvm_object_wrapper)::set(this,
			"m_env.m_wp_alu_agent.m_sequencer.run_phase",
			"default_sequence",
			wp_alu_random_sequence::type_id::get());

       	// Create the env
		super.build_phase(phase);
	endfunction

endclass
`endif // IFNDEF_GUARD_wp_alu_example_test
