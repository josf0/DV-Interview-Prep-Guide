class top_env extends uvm_env;
    `uvm_component_utils(top_env)

    M0_env m0_env;
    M1_env m1_env;
    S0_env s0_env;
    S1_env s1_env;
    S2_env s2_env;
    scoreboard sco;
    virtual_sequencer vseqr;

    function new(string path = "top_env", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m0_env = M0_env::type_id::create("m0_env", this);
        m1_env = M1_env::type_id::create("m1_env", this);
        s0_env = S0_env::type_id::create("s0_env", this);
        s1_env = S1_env::type_id::create("s1_env", this);
        s2_env = S2_env::type_id::create("s2_env", this);
        sco = scoreboard::type_id::create("sco", this);
        vseqr = virtual_sequencer::type_id::create("vseqr", this); //this is needed
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vseqr.m0_seqr = m0_env.m0_a.seqr;
        vseqr.m1_seqr = m1_env.m1_a.seqr;

        m0_env.m0_a.mon.send.connect(sco.master_fifo.analysis_export);
        m1_env.m1_a.mon.send.connect(sco.master_fifo.analysis_export);
        s0_env.s0_a.mon.send.connect(sco.slave_fifo.analysis_export);
        s1_env.s1_a.mon.send.connect(sco.slave_fifo.analysis_export);
        s2_env.s2_a.mon.send.connect(sco.slave_fifo.analysis_export);
    endfunction
endclass