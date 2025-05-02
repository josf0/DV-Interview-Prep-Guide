class S0_agent extends uvm_agent;
    `uvm_component_utils(S0_agent)

    S0_driver drv;
    S0_monitor mon;
    S0_sequencer seqr; 

    function new(string path = "S0_agent", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = S0_driver::type_id::create("drv");
        mon = S0_monitor::type_id::create("mon");
        seqr = S0_sequencer::type_id::create("seqr");
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass

class S1_agent extends uvm_agent;
    `uvm_component_utils(S1_agent)

    S1_driver drv;
    S1_monitor mon;
    S1_sequencer seqr;

    function new(string path = "S1_agent", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = S1_driver::type_id::create("drv");
        mon = S1_monitor::type_id::create("mon");
        seqr = S1_sequencer::type_id::create("seqr");
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass

class S2_agent extends uvm_agent;
    `uvm_component_utils(S2_agent)

    S2_driver drv;
    S2_monitor mon;
    S2_sequencer seqr;

    function new(string path = "S2_agent", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = S2_driver::type_id::create("drv");
        mon = S2_monitor::type_id::create("mon");
        seqr = S2_sequencer::type_id::create("seqr");
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass

