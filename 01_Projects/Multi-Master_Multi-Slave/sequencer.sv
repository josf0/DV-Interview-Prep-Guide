class M0_sequencer extends uvm_sequencer#(packet_transaction);
    `uvm_component_utils(M0_sequencer)

    function new(string path = "M0_sequencer", uvm_component parent = null);
        super.new(path, parent);
    endfunction
endclass

class M1_sequencer extends uvm_sequencer#(packet_transaction);
    `uvm_component_utils(M1_sequencer)

    function new(string path = "M1_sequencer", uvm_component parent = null);
        super.new(path, parent);
    endfunction
endclass

