class test extends uvm_test;
    `uvm_component_utils(test)

    top_env top_e;
    virtual_sequence vseq;

    function new(string path = "test", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        top_e = top_env::type_id::create("top_e", this);
        vseq = virtual_sequence::type_id::create("vseq");
        //uvm_config_db#(uvm_object_wrapper)::set(this, "top_e.vseqr.main_phase", "default_sequence", virtual_sequence::type_id::get());
    endfunction

    virtual task main_phase(uvm_phase phase);
        // vseq = virtual_sequence::type_id::create("vseq", this);
        phase.raise_objection(this);
        `uvm_info("Test", "Starting Virtual Sequence", UVM_NONE);
        vseq.start(top_e.vseqr);
        phase.drop_objection(this);
    endtask
endclass