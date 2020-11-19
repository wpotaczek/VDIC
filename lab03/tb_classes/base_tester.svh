virtual class base_tester extends uvm_component;

	`uvm_component_utils(base_tester)

	virtual alu_bfm bfm;

	function new (string name, uvm_component parent);
  		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
			$fatal(1,"Failed to get BFM");
	endfunction : build_phase

	pure virtual function operation_t get_op();

	pure virtual function byte get_data();

	task run_phase(uvm_phase phase);
		bit [31:0] A;
		bit [31:0] B;
		operation_t op_set;

		phase.raise_objection(this);

		bfm.reset_alu();

		repeat (1000) begin : tester_main
			op_set = get_op();
			A = get_data();
			B = get_data();
			bfm.send_op(A, B, op_set);
		end : tester_main

		phase.drop_objection(this);

	endtask : run_phase 

endclass : base_tester
