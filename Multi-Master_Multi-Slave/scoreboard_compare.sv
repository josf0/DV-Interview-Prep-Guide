class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_tlm_analysis_fifo#(packet_transaction) master_fifo;
    uvm_tlm_analysis_fifo#(packet_transaction) slave_fifo;

    int pass_count = 0;
    int fail_count = 0;

    function new(string path = "scoreboard", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        master_fifo = new("master_fifo", this);
        slave_fifo = new("slave_fifo", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            packet_transaction m_tr, s_tr;
            m_tr = packet_transaction::type_id::create("m_tr");
            s_tr = packet_transaction::type_id::create("s_tr");

            // Get transactions from FIFO
            master_fifo.get(m_tr);
            slave_fifo.get(s_tr);

            if (compare_transactions(m_tr, s_tr)) begin
                pass_count++;
                `uvm_info("SCO", "PASS: Transactions Matched", UVM_NONE);
            end
            else begin
                fail_count++;
                `uvm_error("SCO", $sformatf(
                    "FAIL: Transactions Mismatch\nMaster:\n%s\nSlave:\n%s", 
                    m_tr.sprint(), s_tr.sprint()
                ));
            end
        end
    endtask

    function bit compare_transactions(packet_transaction m_tr, packet_transaction s_tr);
        if (m_tr.sop !== s_tr.sop) return 0;
        if (m_tr.eop !== s_tr.eop) return 0;
        if (m_tr.length !== s_tr.length) return 0;
        if (m_tr.dest !== s_tr.dest) return 0;
        if (m_tr.src !== s_tr.src) return 0;
        if (m_tr.crc !== s_tr.crc) return 0;
        if (!compare_data(m_tr.data, s_tr.data)) return 0;
        if (!compare_keep(m_tr.keep, s_tr.keep)) return 0;
        return 1;
    endfunction

    function bit compare_data(logic [31:0] exp_data[], logic [31:0] act_data[]);
        if (exp_data.size() != act_data.size()) return 0;
        foreach (exp_data[i]) if (exp_data[i] != act_data[i]) return 0;
        return 1;
    endfunction

    function bit compare_keep(logic [3:0] exp_keep[], logic [3:0] act_keep[]);
        if (exp_keep.size() != act_keep.size()) return 0;
        foreach (exp_keep[i]) if (exp_keep[i] != act_keep[i]) return 0;
        return 1;
    endfunction

    virtual function void report_phase(uvm_phase phase);
        `uvm_info("SCO", $sformatf(
            "Final Scoreboard Report: Pass = %0d, Fail = %0d", pass_count, fail_count
        ), UVM_NONE);
    endfunction
endclass
