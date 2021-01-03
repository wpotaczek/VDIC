class sequence_item extends uvm_sequence_item;
//   `uvm_object_utils(sequence_item)

    /*rand byte unsigned A;
    rand byte unsigned B;
    rand operation_t op;
    shortint unsigned result;

    constraint op_con {op dist {no_op := 1, add_op := 5, and_op:=5,
            xor_op:=5,mul_op:=5, rst_op:=1};}

    constraint data { A dist {8'h00:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};
        B dist {8'h00:=1, [8'h01 : 8'hFE]:=1, 8'hFF:=1};}
*/
	rand bit [31:0]   A;
   rand bit [31:0]   B;
   rand operation_t	op;
	bit [39:0] result;

	constraint op_con { op != rst_op;}
	
    function new(string name = "sequence_item");
        super.new(name);
    endfunction : new

	// macros providing copy, compare, pack, record, print functions.
	// Individual functions can be enabled/disabled with the last
	// `uvm_field_*() macro argument.
    `uvm_object_utils_begin(sequence_item)
        `uvm_field_int(A, UVM_ALL_ON)
        `uvm_field_int(B, UVM_ALL_ON)
        `uvm_field_enum(operation_t, op, UVM_ALL_ON)
        `uvm_field_int(result, UVM_ALL_ON)
    `uvm_object_utils_end
/*
    function bit do_compare(uvm_object rhs, uvm_comparer comparer);
        sequence_item tested;
        bit same;

        if (rhs==null) `uvm_fatal(get_type_name(),
                "Tried to do comparison to a null pointer");

        if (!$cast(tested,rhs))
            same = 0;
        else
            same = super.do_compare(rhs, comparer) &&
            (tested.A == A) &&
            (tested.B == B) &&
            (tested.op == op) &&
            (tested.result == result);
        return same;
    endfunction : do_compare

    function void do_copy(uvm_object rhs);
        sequence_item RHS;
        assert(rhs != null) else
            $fatal(1,"Tried to copy null transaction");
        super.do_copy(rhs);
        assert($cast(RHS,rhs)) else
            $fatal(1,"Faied cast in do_copy");
        A      = RHS.A;
        B      = RHS.B;
        op     = RHS.op;
        result = RHS.result;
    endfunction : do_copy
*/
    function string convert2string();
        string s;
        s = $sformatf("A: %2h  B: %2h   op: %s = %4h",
            A, B, op.name(), result);
        return s;
    endfunction : convert2string

endclass : sequence_item



