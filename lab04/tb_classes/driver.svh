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
    uvm_get_port #(command_s) command_port;

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");
        command_port = new("command_port",this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        command_s command;

      forever begin : command_loop
         command_port.get(command);
			/*case (command.op) // handle the start signal        	
         	er_data_op: begin : case_er_data_op 
	         	bfm.send_byte(DATA_TYPE, command.B[31:24]);
        			bfm.send_byte(DATA_TYPE, command.B[23:16]);
        			bfm.send_byte(DATA_TYPE, command.B[15:8]);
        			bfm.send_byte(DATA_TYPE, command.B[7:0]);
        
  					bfm.send_byte(DATA_TYPE, command.A[31:24]);
     				bfm.send_byte(DATA_TYPE, command.A[23:16]);
        			bfm.send_byte(DATA_TYPE, command.A[15:8]);
	         	
	         	bfm.send_byte(CMD_TYPE, {1'b0, add_op, bfm.crc4_generate({command.B,command.A,1'b1,add_op},4'h0)});
	         	bfm.send_byte(1'b1,{8'b11111111});
	         end         	
         	er_crc_op: begin : case_er_crc_op
	         		//crc_error = (bfm.crc4_generate({B,A,1'b1,op},4'h0) + 1'b1);
        			bfm.send_calculation_data(command.B, command.A, and_op, (bfm.crc4_generate({command.B,command.A,1'b1,command.op},4'h0) + 1'b1));
         	end
         	er_op_op: begin : case_er_op_op
	         	bfm.send_calculation_data(command.B, command.A, command.op, bfm.crc4_generate({command.B,command.A,1'b1,command.op},4'h0));
         	end
         	rst_op: begin :rst_op
	         	bfm.reset_alu();
	         end         		
           	default: begin
	         	bfm.send_calculation_data(command.B, command.A, command.op, bfm.crc4_generate({command.B,command.A,1'b1,command.op},4'h0));
           	end
			endcase
			#500;*/
         bfm.send_op(command.A, command.B, command.op);
	      #500;
      end : command_loop
    endtask : run_phase

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : driver
