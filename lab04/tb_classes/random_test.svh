class random_test extends uvm_test;
    `uvm_component_utils(random_test)

    env env_h;

    function void build_phase(uvm_phase phase);	    
        env_h = env::type_id::create("env_h",this);
//        base_tester::type_id::set_type_override(random_tester::get_type());
    endfunction : build_phase

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction : new
    
    function void end_of_elaboration_phase(uvm_phase phase);
	    super.end_of_elaboration_phase(phase);
	    this.print();
    endfunction : end_of_elaboration_phase
    
 /*   
    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        uvm_top.print_topology();
    endfunction : start_of_simulation_phase
*/
endclass


