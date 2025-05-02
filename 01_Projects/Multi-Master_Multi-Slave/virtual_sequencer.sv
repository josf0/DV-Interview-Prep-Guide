class virtual_sequencer extends uvm_sequencer#(packet_transaction);
    `uvm_component_utils(virtual_sequencer);

    M0_sequencer m0_seqr;
    M1_sequencer m1_seqr;

    function new(string path = "virtual_sequencer", uvm_component parent = null);
        super.new(path);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m0_seqr = M0_sequencer::type_id::create("m0_seqr", this);
        m1_seqr = M1_sequencer::type_id::create("m1_seqr", this);
    endfunction
endclass
