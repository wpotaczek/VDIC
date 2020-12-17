/******************************************************************************
* (C) Copyright 2013 <Company Name> All Rights Reserved
*
* MODULE:    name
* DEVICE:
* PROJECT:
* AUTHOR:    wpotaczek
* DATE:      2020 6:07:37 PM
*
* ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
*
*******************************************************************************/

class driver extends uvm_component;
    `uvm_component_utils(driver)

    virtual alu_bfm bfm;
    uvm_get_port #(random_command) command_port;

    function void build_phase(uvm_phase phase);
		alu_agent_config alu_agent_config_h;
	  
      if(!uvm_config_db #(alu_agent_config)::get(this, "","config", alu_agent_config_h))
        `uvm_fatal("DRIVER", "Failed to get config");
		
      bfm = alu_agent_config_h.bfm;
       command_port = new("command_port",this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
	    
	    random_command command;	    

      forever begin : command_loop
         command_port.get(command);
         bfm.send_op(command.A, command.B, command.op);
	      #500;
      end : command_loop
    endtask : run_phase

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : driver
