class S0_env extends uvm_env;
    `uvm_component_utils(S0_env)

    S0_agent s0_a;

    function new(string path = "S0_env", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        s0_a = S0_agent::type_id::create("s0_a", this);
    endfunction

endclass

class S1_env extends uvm_env;
    `uvm_component_utils(S1_env)

    S1_agent s1_a;

    function new(string path = "S1_env", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        s1_a = S1_agent::type_id::create("s1_a", this);
    endfunction

endclass

class S2_env extends uvm_env;
    `uvm_component_utils(S2_env)

    S2_agent s2_a;

    function new(string path = "S2_env", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        s2_a = S2_agent::type_id::create("s2_a", this);
    endfunction

endclass
