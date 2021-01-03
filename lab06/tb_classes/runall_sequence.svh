class runall_sequence extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(runall_sequence)

    protected random_sequence random;
    protected minmax_sequence minmax;

    protected sequencer sequencer_h;
    protected uvm_component uvm_component_h;

    function new(string name = "runall_sequence");
        super.new(name);
	    
        uvm_component_h = uvm_top.find("*.env_h.sequencer_h");

        if (uvm_component_h == null)
            `uvm_fatal("RUNALL SEQUENCE", "Failed to get the sequencer")

        // find function returns uvm_component, needs casting
        if (!$cast(sequencer_h, uvm_component_h))
            `uvm_fatal("RUNALL SEQUENCE", "Failed to cast from uvm_component_h.")

        random       	= random_sequence::type_id::create("random");
        minmax         	= minmax_sequence::type_id::create("minmax");
    endfunction : new

    task body();
        random.start(sequencer_h);
        minmax.start(sequencer_h);
    endtask : body

endclass : runall_sequence




