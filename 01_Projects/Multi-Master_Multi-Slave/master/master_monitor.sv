class M0_monitor extends uvm_monitor;
    `uvm_component_utils(M0_monitor)

    packet_transaction tr;
    uvm_analysis_port#(packet_transaction) send;
    virtual M0_if vif;

    function new(string path = "m0_monitor", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        send = new("send", this);
        if(!uvm_config_db#(virtual M0_if)::get(this, "", "M0_vif", vif))
         `uvm_error("M0_MON", "Unable to access the interface");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            if(vif.rst) begin
                `uvm_info("M0_MON", "System Reset Detected", UVM_NONE);
            end

            else begin
                //wait for SOP and capture Control word
                if(vif.valid && vif.sop) begin
                    tr.sop = vif.sop;
                    tr.eop = vif.eop;
                    tr.length = vif.data[11:0];
                    tr.dest = vif.data[13:12];
                    tr.src = vif.data[15:14];
                    tr.crc = vif.data[23:16];
                    tr.data[0] = vif.data;
                    tr.keep[0] = vif.keep;
                

                    //capture data words
                    for(int i = 1; i <= (tr.length == 12'h00 ? 4096: tr.length); i++) begin
                        wait(vif.ready); 
                        @(posedge vif.clk);
                        tr.data[i] = vif.data;
                        tr.keep[i] = vif.keep;

                        if(i == (tr.length == 12'h000 ? 4096 : tr.length)) begin
                            tr.eop = vif.eop;
                        end
                    end

                    `uvm_info("M0_MON", "Packet captured successfully", UVM_NONE);
                    tr.sample_coverage();
                    send.write(tr);
                end
            end
        end
    endtask
endclass

class M1_monitor extends uvm_monitor;
    `uvm_component_utils(M1_monitor)

    packet_transaction tr;
    uvm_analysis_port#(packet_transaction) send;
    virtual M1_if vif;

    function new(string path = "M1_monitor", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        send = new("send", this);
        if(!uvm_config_db#(virtual M1_if)::get(this, "", "M1_vif", vif))
         `uvm_error("M1_MON", "Unable to access the interface");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            if(vif.rst) begin
                `uvm_info("M1_MON", "System Reset Detected", UVM_NONE);
            end

            //wait for SOP and capture Control word
            wait(vif.m_valid && vif.m_ready && vif.sop);
            @(posedge vif.clk);
            tr.sop = vif.sop;
            tr.eop = vif.eop;
            tr.length = vif.data[11:0];
            tr.dest = vif.data[13:12];
            tr.src = vif.data[15:14];
            tr.crc = vif.data[23:16];
            tr.data[0] = vif.data;
            tr.keep[0] = vif.keep;
            //capture data words
            for(int i = 1; i <= (tr.length == 12'h00 ? 4096: tr.length); i++) begin 
                @(posedge vif.clk iff (vif.m_valid && vif.m_ready));
                tr.data[i] = vif.data;
                tr.keep[i] = vif.keep;
                // Capture EOP when last word is received
                if (i == ((tr.length == 12'h000) ? 4096 : tr.length)) begin
                    tr.eop = vif.eop;
                end
            end
            `uvm_info("M1_MON", "Packet captured successfully", UVM_NONE);
            send.write(tr);
        end
    endtask
endclass
