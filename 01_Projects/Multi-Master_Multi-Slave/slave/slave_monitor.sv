class S0_monitor extends uvm_monitor;
    `uvm_component_utils(S0_monitor)

    uvm_analysis_port#(packet_transaction) send;
    virtual S0_if vif;
    packet_transaction tr;

    function new(string path = "S0_monitor", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        send = new("send", this);
        if (!uvm_config_db#(virtual S0_if)::get(this, "", "S0_vif", vif))
            `uvm_error("S0_MON", "Unable to access the interface");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            
            // Handle Reset
            if (vif.rst) begin
                `uvm_info("S0_MON", "System Reset Detected - Sending Empty Transaction", UVM_NONE);
            end

            else begin
                wait(vif.s_valid && vif.s_ready && vif.sop);
                @(posedge vif.clk);
                tr.sop = vif.sop;
                tr.eop = vif.eop;
                tr.length = vif.data[11:0];
                tr.dest = vif.data[13:12];
                tr.src = vif.data[15:14];
                tr.crc = vif.data[23:16];
                tr.data[0] = vif.data;
                tr.keep[0] = vif.keep;
                // Capture Data Words
                for (int i = 0; i <= (tr.length == 12'h000 ? 4096 : tr.length); i++) begin
                    @(posedge vif.clk iff (vif.s_valid && vif.s_ready));
                    tr.data[i] = vif.data;
                    tr.keep[i] = vif.keep;
                    if(i == (tr.length == 12'h000) ? 4096: tr.length) begin
                        tr.eop = vif.eop;
                    end
                end

                `uvm_info("S0_MON", "Packet Captured Successfully", UVM_NONE);
                tr.sample_coverage();
                // Send transaction to scoreboard
                send.write(tr); 
            end 
        end
    endtask
endclass


class S1_monitor extends uvm_monitor;
    `uvm_component_utils(S1_monitor)

    uvm_analysis_port#(packet_transaction) send;
    virtual S1_if vif;
    packet_transaction tr;

    function new(string path = "S1_monitor", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        send = new("send", this);
        if (!uvm_config_db#(virtual S1_if)::get(this, "", "S1_vif", vif))
            `uvm_error("S1_MON", "Unable to access the interface");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            
            // Handle Reset
            if (vif.rst) begin
                `uvm_info("S1_MON", "System Reset Detected - Sending Empty Transaction", UVM_NONE);
            end

            // Wait for SOP
            wait(vif.s_valid && vif.s_ready && vif.sop);
            @(posedge vif.clk);
            tr.sop = vif.sop;
            tr.eop = vif.eop;
            tr.length = vif.data[11:0];
            tr.dest = vif.data[13:12];
            tr.src = vif.data[15:14];
            tr.crc = vif.data[23:16];
            tr.data[0] = vif.data;
            tr.keep[0] = vif.keep;
            // Capture Data Words
            for (int i = 0; i <= (tr.length == 12'h000 ? 4096 : tr.length); i++) begin
                @(posedge vif.clk iff (vif.s_valid && vif.s_ready));
                tr.data[i] = vif.data;
                tr.keep[i] = vif.keep;

                if (i == (tr.length == 12'h000 ? 4096 : tr.length)) begin
                    tr.eop = vif.eop;
                end
            end

            `uvm_info("S1_MON", "Packet Captured Successfully", UVM_NONE);
            // Send transaction to scoreboard
            send.write(tr);  
        end
    endtask
endclass

class S2_monitor extends uvm_monitor;
    `uvm_component_utils(S2_monitor)

    uvm_analysis_port#(packet_transaction) send;
    virtual S1_if vif;
    packet_transaction tr;

    function new(string path = "S2_monitor", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        send = new("send", this);
        if (!uvm_config_db#(virtual S1_if)::get(this, "", "S2_vif", vif))
            `uvm_error("S2_MON", "Unable to access the interface");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            
            // Handle Reset
            if (vif.rst) begin
                `uvm_info("S2_MON", "System Reset Detected - Sending Empty Transaction", UVM_NONE);
            end

            // Wait for SOP
            wait(vif.s_valid && vif.s_ready && vif.sop);
            @(posedge vif.clk);
            tr.sop = vif.sop;
            tr.eop = vif.eop;
            tr.length = vif.data[11:0];
            tr.dest = vif.data[13:12];
            tr.src = vif.data[15:14];
            tr.crc = vif.data[23:16];
            tr.data[0] = vif.data;
            tr.keep[0] = vif.keep;
            // Capture Data Words
            for (int i = 0; i <= (tr.length == 12'h000 ? 4096 : tr.length); i++) begin
                @(posedge vif.clk iff (vif.s_valid && vif.s_ready));
                tr.data[i] = vif.data;
                tr.keep[i] = vif.keep;

                if (i == (tr.length == 12'h000 ? 4096 : tr.length)) begin
                    tr.eop = vif.eop;
                end
            end

            `uvm_info("S2_MON", "Packet Captured Successfully", UVM_NONE);
            // Send transaction to scoreboard
            send.write(tr);  
        end
    endtask
endclass