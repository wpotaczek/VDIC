class minmax_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(minmax_sequence)

    sequence_item command;

    function new(string name = "minmax_sequence");
        super.new(name);
    endfunction : new

    task body();
        `uvm_info("SEQ_MINMAX","",UVM_MEDIUM)
        
//       command = sequence_item::type_id::create("command");
        `uvm_create(command);
	    
	     command.op = rst_op;
	     `uvm_send(command);
        
        repeat (5000) begin : random_loop
//         start_item(command);
//         assert(command.randomize());
//         finish_item(command);
           `uvm_rand_send_with(command, { A dist {32'h0000_0000:/10, [32'h0000_0001 : 32'hFFFF_FFFE]:/1, 32'hFFFF_FFFF:/10};B dist {32'h0000_0000:/10, [32'h0000_0001 : 32'hFFFF_FFFE]:/1, 32'hFFFF_FFFF:/10};})
//        `uvm_rand_send_with(command,{command.A inside {32'h0, 32'hFFFF_FFFF};
                                      //command.B inside {32'h0, 32'hFFFF_FFFF};})      
	        
        end : random_loop
        //#500;
    endtask : body

endclass : minmax_sequence

