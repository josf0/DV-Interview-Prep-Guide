class M0_env extends uvm_env;
    `uvm_component_utils(M0_env)

    M0_agent m0_a;

    function new(string path = "M0_env", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m0_a = M0_agent::type_id::create("m0_a", this);
    endfunction

endclass

class M1_env extends uvm_env;
    `uvm_component_utils(M1_env)

    M1_agent m1_a;

    function new(string path = "M1_env", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m1_a = M1_agent::type_id::create("m1_a", this);
    endfunction

endclass
