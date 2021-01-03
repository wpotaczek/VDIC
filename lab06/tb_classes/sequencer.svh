/******************************************************************************
* DVT CODE TEMPLATE: sequencer
* Created by Robert Szczygiel on Jan 3, 2019
* uvc_company = kmie, uvc_name = tinyALU
*******************************************************************************/

`ifndef IFNDEF_GUARD_mtm_tinyALU_sequencer
`define IFNDEF_GUARD_mtm_tinyALU_sequencer

//------------------------------------------------------------------------------
//
// CLASS: sequencer
//
//------------------------------------------------------------------------------

class sequencer extends uvm_sequencer #(sequence_item);
	
	`uvm_component_utils(sequencer)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : sequencer

`endif // IFNDEF_GUARD_mtm_tinyALU_sequencer

