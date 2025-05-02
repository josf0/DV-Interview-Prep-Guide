// Code your design here
module sequence_detector(
    input logic clk,
    input logic reset,
    input logic data_in,
    output logic out
);
    //state encoding
  typedef enum logic [2:0] {IDLE, S1, S11, S110, S1101} state_t;

    state_t state, next;

    always_ff @(posedge clk or posedge reset) begin
        if(reset) state <= IDLE;
        else state <= next;
    end

    always_comb begin
        next = IDLE;
        out = 0;
        case(state)
            IDLE: begin
                next = (data_in == 1) ? S1: IDLE;
            end

            S1: begin
                next = (data_in == 1) ? S11: IDLE;
            end

            S11: begin
                next = (data_in == 1) ? S11 : S110;
            end

            S110: begin
              next = (data_in == 1) ? S1101 : IDLE;
            end
          
           S1101: begin
             out = 1'b1;
             next = (data_in == 1) ? S11 : IDLE;
           end
            default: begin
                next = IDLE;
            end
        endcase
    end
endmodule

interface sequence_detector_if(input logic clk);
    logic reset;
    logic data_in;
    logic out;
endinterface

// Code your testbench here
// or browse Examples
`include "uvm_macros.svh"
import uvm_pkg::*;
class sequence_transaction extends uvm_sequence_item;
    `uvm_object_utils(sequence_transaction)

    rand bit data_in;
    rand bit reset;
    bit out;

    function new(string path = "sequence_transaction");
        super.new(path);
    endfunction
endclass

class sequence_seq extends uvm_sequence#(sequence_transaction);
    `uvm_object_utils(sequence_seq)

    function new(string name = "sequence_seq");
        super.new(name);
    endfunction

    virtual task body();
        sequence_transaction tr;
       bit [3:0] seq_pattern = 4'b1101;
      
      tr = sequence_transaction::type_id::create("tr");
      start_item(tr);
      tr.reset = 1;
      finish_item(tr);
      
       for (int i = 0; i < 20; i++) begin
        tr = sequence_transaction::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize());
        case (i % 4)
                0: tr.data_in = 1;   // First bit (1)
                1: tr.data_in = 1;   // Second bit (1)
                2: tr.data_in = 0;   // Third bit (0)
                3: tr.data_in = 1;   // Fourth bit (1)
            endcase
        tr.reset = 0;
        finish_item(tr);
      end
    endtask
endclass

class sequence_driver extends uvm_driver#(sequence_transaction);
    `uvm_component_utils(sequence_driver)

    virtual sequence_detector_if vif;
  
  function new(string path = "sequence_driver", uvm_component parent = null);
    super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual sequence_detector_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Failed to access virtual interface")
    endfunction

    virtual task run_phase(uvm_phase phase);
        sequence_transaction tr;
        forever begin
            seq_item_port.get_next_item(tr);
            vif.data_in <= tr.data_in;
            vif.reset <= tr.reset;
            @(posedge vif.clk);
            seq_item_port.item_done();
        end
    endtask
endclass

class sequence_monitor extends uvm_monitor;
    `uvm_component_utils(sequence_monitor)

    virtual sequence_detector_if vif;
    uvm_analysis_port#(sequence_transaction) send;

  function new(string path = "sequence_monitor", uvm_component parent = null);
    super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
      send = new("send", this);
        if(!uvm_config_db#(virtual sequence_detector_if)::get(this, "", "vif", vif))
          `uvm_error("MON", "Unable to access monitor")
    endfunction

    virtual task run_phase(uvm_phase phase);
        sequence_transaction tr;
        forever begin
            tr = sequence_transaction::type_id::create("tr");
          tr.data_in = vif.data_in;
            tr.reset = vif.reset;
          @(posedge vif.clk);
          tr.out = vif.out;
          `uvm_info("MON", $sformatf("data_in: %0b, out:%0b", tr.data_in, tr.out), UVM_MEDIUM)
            send.write(tr);
        end
    endtask
endclass

class sequence_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(sequence_scoreboard)

  	sequence_transaction tr;
    uvm_analysis_imp#(sequence_transaction, sequence_scoreboard) recv;
  bit [3:0] pattern = 4'b0000;

  function new(string path = "sequence_scoreboard", uvm_component parent = null);
    super.new(path, parent);
    endfunction
  
  virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        recv = new("recv", this);
    tr = sequence_transaction::type_id::create("tr");
    endfunction

    virtual function void write(sequence_transaction tr);
      pattern = {pattern[2:0], tr.data_in};
        `uvm_info("SCO", $sformatf("data_in:%0b",tr.data_in), UVM_MEDIUM)
      `uvm_info("SCO", $sformatf("pattern:%0b",pattern), UVM_MEDIUM)
        if (pattern == 4'b1101) begin
          if (tr.out != 1'b1)
                `uvm_error("SCO", "Output mismatch - Expected 1 but got 0")
            else
                `uvm_info("SCO", "Correct Detection of 1101", UVM_MEDIUM)
        end
        else begin
          `uvm_info("SCO","Pattern not detected", UVM_MEDIUM)
        end
    endfunction
endclass
              
class sequence_sequencer extends uvm_sequencer#(sequence_transaction);
    `uvm_component_utils(sequence_sequencer)
  	
  	function new(string path = "sequence_sequencer", uvm_component parent = null);
    super.new(path, parent);
    endfunction
  
endclass
          
class sequence_agent extends uvm_agent;
    `uvm_component_utils(sequence_agent)

    sequence_driver drv;
    sequence_monitor mon;
    sequence_sequencer seqr;
  
  function new(string path = "sequence_agnt", uvm_component parent = null);
    super.new(path, parent);
    endfunction


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = sequence_driver::type_id::create("drv", this);
        mon = sequence_monitor::type_id::create("mon", this);
        seqr = sequence_sequencer::type_id::create("seqr", this);
    endfunction

   virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass

class sequence_env extends uvm_env;
    `uvm_component_utils(sequence_env)

    sequence_agent agt;
    sequence_scoreboard sb;
  
  function new(string path = "sequence_env", uvm_component parent = null);
    super.new(path, parent);
    endfunction


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agt = sequence_agent::type_id::create("agt", this);
        sb = sequence_scoreboard::type_id::create("sb", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agt.mon.send.connect(sb.recv);
    endfunction
endclass    
          
class sequence_test extends uvm_test;
    `uvm_component_utils(sequence_test)

    sequence_env env;
    sequence_seq seq;
  
  function new(string path = "sequence_test", uvm_component parent = null);
    super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = sequence_env::type_id::create("env", this);
      seq = sequence_seq::type_id::create("seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);

      	seq.start(env.agt.seqr);

        phase.drop_objection(this);
    endtask
endclass
module tb_sequence_detector;

    logic clk;
    sequence_detector_if vif(clk);

    sequence_detector dut (
        .clk(vif.clk),
        .reset(vif.reset),
        .data_in(vif.data_in),
        .out(vif.out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns Clock Period
    end

    initial begin
        uvm_config_db#(virtual sequence_detector_if)::set(null, "*", "vif", vif);
        run_test("sequence_test");
    end


endmodule