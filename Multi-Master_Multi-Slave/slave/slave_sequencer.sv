class S0_sequencer extends uvm_sequencer#(packet_transaction)
    `uvm_component_utils(S0_sequencer)

    function new(string path = "S0_sequencer", uvm_component parent = null);
        super.new(path, parent);
    endfunction
endclass

class S1_sequencer extends uvm_sequencer#(packet_transaction)
    `uvm_component_utils(S1_sequencer)

    function new(string path = "S1_sequencer", uvm_component parent = null);
        super.new(path, parent);
    endfunction
endclass

class S2_sequencer extends uvm_sequencer#(packet_transaction)
    `uvm_component_utils(S2_sequencer)

    function new(string path = "S2_sequencer", uvm_component parent = null);
        super.new(path, parent);
    endfunction
endclass


