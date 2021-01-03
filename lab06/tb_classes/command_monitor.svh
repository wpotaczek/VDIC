class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

    virtual alu_bfm bfm;
	
    uvm_analysis_port #(sequence_item) ap;
	
    function void build_phase(uvm_phase phase);

        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("COMMAND MONITOR", "Failed to get BFM")
        ap                    = new("ap",this);
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
	    bfm.command_monitor_h = this;
    endfunction : connect_phase

		function void write_to_monitor(bit [31:0] A, bit [31:0] B, operation_t op );
     		//$display("COMMAND MONITOR: A:0x%2h B:0x%2h op: %s", cmd.A, cmd.B, cmd.op.name());
        	sequence_item cmd;
	    	`uvm_info("COMMAND MONITOR",$sformatf("MONITOR: A: %2h  B: %2h  op: %s",
                A, B, op.name()), UVM_HIGH);
	    	cmd 		= new("cmd");
	    	cmd.A 	= A;
	    	cmd.B 	= B;
	    	cmd.op	= op;	    
			ap.write(cmd);
    	endfunction : write_to_monitor

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

endclass : command_monitor

