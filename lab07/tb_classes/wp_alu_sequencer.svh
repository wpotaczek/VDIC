/******************************************************************************
* DVT CODE TEMPLATE: sequencer
* Created by wpotaczek on Jan 22, 2021
* uvc_company = wp, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_wp_alu_sequencer
`define IFNDEF_GUARD_wp_alu_sequencer

//------------------------------------------------------------------------------
//
// CLASS: wp_alu_sequencer
//
//------------------------------------------------------------------------------

class wp_alu_sequencer extends uvm_sequencer #(wp_alu_item);
	
	`uvm_component_utils(wp_alu_sequencer)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : wp_alu_sequencer

`endif // IFNDEF_GUARD_wp_alu_sequencer
