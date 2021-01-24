/******************************************************************************
* DVT CODE TEMPLATE: coverage collector
* Created by wpotaczek on Jan 22, 2021
* uvc_company = wp, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_wp_alu_coverage_collector
`define IFNDEF_GUARD_wp_alu_coverage_collector

//------------------------------------------------------------------------------
//
// CLASS: wp_alu_coverage_collector
//
//------------------------------------------------------------------------------

class wp_alu_coverage_collector extends uvm_component;

	// Configuration object
	protected wp_alu_config_obj m_config_obj;

	// Item collected from the monitor
	protected wp_alu_item m_collected_item;

	// Using suffix to handle more ports
	`uvm_analysis_imp_decl(_collected_item)

	// Connection to the monitor
	uvm_analysis_imp_collected_item#(wp_alu_item, wp_alu_coverage_collector) m_monitor_port;

	// TODO: More items and connections can be added if needed

	`uvm_component_utils(wp_alu_coverage_collector)

	covergroup item_cg;
		option.per_instance = 1;
		// TODO add coverpoints here
		
	endgroup : item_cg

	function new(string name, uvm_component parent);
		super.new(name, parent);
		item_cg=new;
		item_cg.set_inst_name({get_full_name(), ".item_cg"});
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		m_monitor_port = new("m_monitor_port",this);

		// Get the configuration object
		if(!uvm_config_db#(wp_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".m_config_obj"})
	endfunction : build_phase

	function void write_collected_item(wp_alu_item item);
		m_collected_item = item;
		item_cg.sample();
	endfunction : write_collected_item

endclass : wp_alu_coverage_collector

`endif // IFNDEF_GUARD_wp_alu_coverage_collector
