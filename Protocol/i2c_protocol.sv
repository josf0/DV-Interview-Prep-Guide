//I2C driver
class I2c_driver extends uvm_driver#(packet_transaction);
    packet_transaction tr;

    virtual task run_phase(uvm_phase phase);
        forever begin
            tr = packet_transaction::type_id::create("tr");
            seq_item_port.get_next_item(tr);
                //start condition
                vif.sda <= 1'b0;
                @(posedge vif.clk);
                vif.scl <= 1'b0;
    
                //address + r/w
                bit [7:0] addr_rw = {tr.addr, tr.rw};
                for(int i = 7; i >= 0; i --) begin
                    vif.sda <= addr_rw[i];
                    @(posedge vif.clk);
                    vif.scl <= 1'b1;
                    @(posedge vif.clk);
                    vif.scl <= 1'b0;
                end
    
                //receive acknowledge
                @(posedge vif.clk);
                vif.scl <= 1'b1;
                @(posedge vif.clk);
                tr.ack = !vif.sda;
                vif.scl <= 1'b0;
    
                if(!tr.rw) begin
                    //write mode
                    for(int idx = 0; idx < tr.wdata.size(); idx++) begin
                        bit [7:0] data_byte = tr.wdata[idx]; //extract the byte 
                        for(int i = 7; i >= 0; i-- ) begin
                            vif.sda <= data_byte[i];
                            @(posedge vif.clk);
                            vif.scl <= 1'b1;
                            @(posedge vif.clk);
                            vif.scl <= 1'b0;
                        end
                        //ACK/NACK
                        @(posedge vif.clk);
                        vif.scl <= 1'b1;
                        @(posedge vif.clk);
                        tr.ack = !vif.sda;
                        vif.scl <= 1'b0; 
                    end
                end 
                else begin
                    //read mode
                    bit [7:0] byte_data = 0;
                    for(int i = 7; i >= 0; i--) begin
                        vif.scl <= 1'b1;
                        @(posedge vif.clk);
                        byte_data[i] = vif.sda;
                        vif.scl <= 1'b0;
                    end
    
                    tr.rdata.push_back(byte_data);
                    //ACK/NACK
                    vif.sda <= tr.ack ? 1'b1 : 1'b0;
                    @(posedge vif.clk);
                end
    
                //STOp condition
                vif.scl <= 1'b1;
                @(posedge vif.clk);
                vif.sda <= 1'b1;
    
            seq_item_port.item_done();
        end
    endtask
endclass

//I2C Transaction and sequence
class i2c_transaction extends uvm_sequence_item;
    `uvm_object_utils(i2c_transaction)

    rand bit [6:0] addr;
    rand bit rw;
    bit [7:0] wdata[$];
    bit [7:0] rdata[$];
    bit ack;
    
    //constraint for valid address
    constraint valid_addr {
        addr inside {[7'b00000000: 7'h7F]};
    }

    //one way to fill the queue
    function void post_randomize();
      //if wdata queue is randomized 
      wdata.delete();
      for(int i = 0; i < $urandom_range(1, 32); i++) begin
          wdata.push_back($urandom_range(1, 255));
      end
    endfunction
    
endclass

class i2c_sequence extends uvm_sequence#(i2c_transaction);
    `uvm_object_utils(i2c_sequence)

    //function new
    virtual task body();
        i2c_transaction tr;
        tr = i2c_transaction::type_id::create("tr");

        start_item(tr);
        assert(tr.randomize());
        if(!tr.rw) begin
            int num_bytes = $urandom_range(1, 32);
            tr.data = {};
            for(int i = 0; i < num_bytes; i++ ) begin
                tr.data.push_back($urandom_range(0, 255));
            end
        end
        finish_item(tr);
    endtask
endclass

//Clock stretching in I2C

// Clock stretching handler
class i2c_driver extends uvm_driver #(i2c_txn);

    task wait_scl_ready();
        while (vif.scl_stretched == 1'b0) @(posedge vif.clk);
        vif.scl <= 1'b1;
        @(posedge vif.clk);
        vif.scl <= 1'b0;
    endtask

 task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(tr);

      // START
      vif.sda <= 1'b0;
      @(posedge vif.clk);
      vif.scl <= 1'b0;

      // address + R/W
      bit [7:0] addr_rw = {tr.addr, tr.rw};
      for (int i = 7; i >= 0; i--) begin
        vif.sda <= addr_rw[i];
        @(posedge vif.clk);
        wait_scl_ready();
      end

      // ACK
      @(posedge vif.clk);
      wait_scl_ready();
      tr.ack = !vif.sda;
      vif.scl <= 1'b0;

      if (!tr.rw) begin
        foreach (tr.data[idx]) begin
          bit [7:0] data_byte = tr.data[idx];
          for (int i = 7; i >= 0; i--) begin
            vif.sda <= data_byte[i];
            @(posedge vif.clk);
            wait_scl_ready();
          end
          @(posedge vif.clk);
          wait_scl_ready();
          tr.ack = !vif.sda;
          vif.scl <= 1'b0;
        end
      end else begin
        bit [7:0] byte_data;
        for (int i = 7; i >= 0; i--) begin
          wait_scl_ready();
          @(posedge vif.clk);
          byte_data[i] = vif.sda;
          vif.scl <= 1'b0;
        end
        tr.data.push_back(byte_data);
        @(posedge vif.clk);
        vif.sda <= tr.ack ? 1'b1 : 1'b0;
      end

      // STOP
      vif.scl <= 1'b1;
      @(posedge vif.clk);
      vif.sda <= 1'b1;

      seq_item_port.item_done();
    end
  endtask
endclass

//---------------------------
// i2c_monitor.sv
//---------------------------
class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)
  
    virtual i2c_if vif;
    uvm_analysis_port #(i2c_txn) ap;
  
    function new(string name, uvm_component parent);
      super.new(name, parent);
      ap = new("ap", this);
    endfunction
  
    task run_phase(uvm_phase phase);
      forever begin
        i2c_txn tr = i2c_txn::type_id::create("tr");
        @(posedge vif.clk);
        wait(vif.sda == 1'b0); // START
        repeat(8) @(posedge vif.clk); // addr + rw
  
        // Simulate clock stretching by slave
        vif.scl_stretched = 1'b0;
        #20;
        vif.scl_stretched = 1'b1;
  
        @(posedge vif.clk); tr.ack = !vif.sda;
        repeat(8) @(posedge vif.clk); // 1st data
        @(posedge vif.clk); tr.ack = !vif.sda;
        ap.write(tr);
      end
    endtask
endclass
  
  
  //---------------------------
  // i2c_predictor.sv
  //---------------------------
class i2c_predictor extends uvm_component;
    `uvm_component_utils(i2c_predictor)
  
    uvm_analysis_imp #(i2c_txn, i2c_predictor) input_ap;
    uvm_analysis_port #(i2c_txn) expected_ap;
  
    function new(string name, uvm_component parent);
      super.new(name, parent);
      input_ap = new("input_ap", this);
      expected_ap = new("expected_ap", this);
    endfunction
  
    function void write(i2c_txn tr);
      i2c_txn exp_tr = new();
      exp_tr.addr = tr.addr;
      exp_tr.data = tr.data;
      exp_tr.rw = tr.rw;
      exp_tr.ack = tr.ack;
      expected_ap.write(exp_tr);
    endfunction
endclass
  
  
  //---------------------------
  // i2c_scoreboard.sv using analysis_imp port
  //---------------------------
class i2c_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(i2c_scoreboard)

  uvm_analysis_imp #(i2c_txn, i2c_scoreboard) actual_ap;
  uvm_analysis_imp #(i2c_txn, i2c_scoreboard) expected_ap;

  i2c_txn actual_q[$];
  i2c_txn expected_q[$];

  function new(string name, uvm_component parent);
      super.new(name, parent);
      actual_ap = new("actual_ap", this);
      expected_ap = new("expected_ap", this);
  endfunction

  task write(i2c_txn tr);
      actual_q.push_back(tr);
      compare();
  endtask

  task write_expected(i2c_txn tr);
      expected_q.push_back(tr);
      compare();
  endtask

  function void compare();
      if (actual_q.size() > 0 && expected_q.size() > 0) begin
          i2c_txn a = actual_q.pop_front();
          i2c_txn e = expected_q.pop_front();

          if (a.addr !== e.addr || a.rw !== e.rw || a.wdata.size() !== e.wdata.size()) begin
              `uvm_error("SCOREBOARD", "Address/RW/WData length mismatch")
              return;
          end

          foreach (a.wdata[i]) begin
              if (a.wdata[i] !== e.wdata[i]) begin
                  `uvm_error("SCOREBOARD", $sformatf("Mismatch at byte %0d: expected %0h, got %0h", i, e.wdata[i], a.wdata[i]))
              end
          end
      end
  endfunction
endclass

//If we are using uvm_tlm_analysis_fifo then we don't need to use a queue for storage 
class i2c_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(i2c_scoreboard)

  uvm_tlm_analysis_fifo#(i2c_txn) expected_fifo;
  uvm_tlm_analysis_fifo#(i2c_txn) actual_fifo;

  function new(string name, uvm_component parent);
      super.new(name, parent);
      expected_fifo = new("expected_fifo", this);
      actual_fifo   = new("actual_fifo", this);
  endfunction

  task run_phase(uvm_phase phase);
      i2c_txn exp, act;

      forever begin
          expected_fifo.get(exp);
          actual_fifo.get(act);

          if (exp.addr !== act.addr || exp.rw !== act.rw || exp.wdata.size() !== act.wdata.size()) begin
              `uvm_error("SCOREBOARD", "Address/RW/WData size mismatch")
              continue;
          end

          foreach (exp.wdata[i]) begin
              if (exp.wdata[i] !== act.wdata[i]) begin
                  `uvm_error("SCOREBOARD", $sformatf("Data mismatch at byte %0d: expected %0h, got %0h", i, exp.wdata[i], act.wdata[i]))
              end
          end

          if (exp.rw == 1) begin
              if (exp.rdata.size() !== act.rdata.size()) begin
                  `uvm_error("SCOREBOARD", "Read data size mismatch")
                  continue;
              end
              foreach (exp.rdata[i]) begin
                  if (exp.rdata[i] !== act.rdata[i]) begin
                      `uvm_error("SCOREBOARD", $sformatf("Read data mismatch at byte %0d: expected %0h, got %0h", i, exp.rdata[i], act.rdata[i]))
                  end
              end
          end

          if (exp.ack !== act.ack) begin
              `uvm_error("SCOREBOARD", $sformatf("ACK mismatch: expected %0b, got %0b", exp.ack, act.ack))
          end
      end
  endtask
endclass

//inside env connection
class env extends uvm_env;

    i2c_driver      drv;
    i2c_monitor     mon;
    i2c_predictor   pred;
    i2c_scoreboard  sco;

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    
          // Predictor receives transaction from driver
          drv.analysis_port.connect(pred.input_ap);
      
          // Monitor sends actual transactions to scoreboard
          mon.ap.connect(sco.actual_ap);
      
          // Predictor sends expected transactions to scoreboard
          pred.expected_ap.connect(sco.expected_ap);
    endfunction
endclass
