class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    packet_transaction m_tr, s_tr;
    uvm_tlm_analysis_fifo#(packet_transaction) master_fifo;
    uvm_tlm_analysis_fifo#(packet_transaction) slave_fifo;

    int pass_count = 0;
    int fail_count = 0;

    function new(string path = "scoreboard", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        m_tr = packet_transaction::type_id::create("m_tr");
        s_tr = packet_transaction::type_id::create("s_tr");
        master_fifo = new("master_fifo", this);
        slave_fifo = new("slave_fifo", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            master_fifo.get(m_tr);
            slave_fifo.get(s_tr);

            if(m_tr.compare(s_tr)) begin
                pass_count++;
                `uvm_info("SCO", "PASS: Transactions Matched", UVM_NONE);
            end
            else begin
                fail_count++;
                `uvm_error("SCO", $sformatf("FAIL: Transactions Mismatch\nMaster:\n%s\nSlave:\n%s", m_tr.sprint(), s_tr.sprint()));
                //UVM_ERROR @ <time> [SCO] FAIL: Transaction Mismatch
                // Master:
                // sop=1 eop=0 length=32 dest=2 src=0 crc=8A data={00,11,22,33,...} keep={F,F,F,F,...}
                // Slave:
                // sop=1 eop=0 length=32 dest=2 src=0 crc=FF data={00,11,22,44,...} keep={F,F,F,0,...}
            end
        end
    endtask

    virtual function void report_phase(uvm_phase phase);
        `uvm_info("SCO", $sformatf("Final Scoreboard Report: pass = %0d, Fail = %0d", pass_count, fail_count), UVM_NONE);
    endfunction
endclass
        