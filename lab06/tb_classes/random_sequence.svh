class random_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(random_sequence)

    sequence_item command;

    function new(string name = "random_sequence");
        super.new(name);
    endfunction : new

    task body();
        `uvm_info("SEQ_RANDOM","",UVM_MEDIUM)
        
//       command = sequence_item::type_id::create("command");
        `uvm_create(command);
	    
	    command.op = rst_op;
	    `uvm_send(command);
        
        repeat (1000) begin : random_loop
//         start_item(command);
//         assert(command.randomize());
//         finish_item(command);
           `uvm_rand_send(command)
        end : random_loop
        //#500;
    endtask : body

endclass : random_sequence












