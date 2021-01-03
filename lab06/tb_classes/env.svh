class env extends uvm_env;
	`uvm_component_utils(env)

	sequencer sequencer_h;
	coverage coverage_h;
   scoreboard scoreboard_h;
	driver driver_h;
	command_monitor command_monitor_h;
	result_monitor result_monitor_h;
	
	function void build_phase(uvm_phase phase);
		
		//stimulus
		sequencer_h			= sequencer::type_id::create("sequencer_h",this);
		driver_h          = driver::type_id::create("drive_h",this);
      
      //monitors
      command_monitor_h = command_monitor::type_id::create("command_monitor_h",this);
      result_monitor_h  = result_monitor::type_id::create("result_monitor_h",this);
      
      //analysis
      coverage_h        = coverage::type_id::create ("coverage_h",this);
      scoreboard_h      = scoreboard::type_id::create("scoreboard_h",this);
	endfunction : build_phase

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new
    
	function void connect_phase(uvm_phase phase);
   	driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
      command_monitor_h.ap.connect(coverage_h.analysis_export);
      command_monitor_h.ap.connect(scoreboard_h.cmd_f.analysis_export);
      result_monitor_h.ap.connect(scoreboard_h.analysis_export);
	endfunction : connect_phase

    function void report_phase(uvm_phase phase);
	    scoreboard_h.print_results();	
    endfunction : report_phase

    function void end_of_elaboration_phase(uvm_phase phase);
        scoreboard_h.set_report_verbosity_level_hier(UVM_HIGH);
    endfunction : end_of_elaboration_phase

endclass


