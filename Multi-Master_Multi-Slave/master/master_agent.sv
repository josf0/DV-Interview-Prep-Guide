class M0_agent extends uvm_agent;
    `uvm_component_utils(M0_agent)

    M0_driver drv;
    M0_monitor mon;
    // M0_reference_monitor mon_ref;
    M0_sequencer seqr;

    function new(string path = "M0_agent", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = M0_driver::type_id::create("drv", this);
        mon = M0_monitor::type_id::create("mon", this);
        // mon_ref = M0_reference_monitor::type_id::create("mon_ref", this);
        seqr = M0_sequencer::type_id::create("seqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass

class M1_agent extends uvm_agent;
    `uvm_component_utils(M1_agent)

    M1_driver drv;
    M1_monitor mon;
    // M1_reference_monitor mon_ref;
    M1_sequencer seqr;

    function new(string path = "M1_agent", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = M1_driver::type_id::create("drv", this);
        mon = M1_monitor::type_id::create("mon", this);
        // mon_ref = M1_reference_monitor::type_id::create("mon_ref", this);
        seqr = M1_sequencer::type_id::create("seqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass

