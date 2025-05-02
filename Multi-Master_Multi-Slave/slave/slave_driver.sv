//slave 0
class S0_driver extends uvm_driver#(packet_transaction);
    `uvm_component_utils(S0_driver)

    virtual S_if vif;
    packet_transaction tr;
    
    function new(string path = "S0_driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual S0_if)::get(this, "", "S_vif", vif))
            `uvm_error("S0_DRV", "Unable to access the interface S0");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tr);
            @(posedge vif.clk);
            
            if(vif.rst) begin
                `uvm_info("S0_DRV", "System Reset Detected", UVM_NONE);
            end

            else begin
                vif.s_ready <= 1;
                wait(vif.s_valid && vif.sop);
                @(posedge vif.clk);
                tr.sop = vif.sop;
                tr.eop = vif.eop;
                tr.length = vif.data[11:0];
                tr.dest = vif.data[13:12];
                tr.src = vif.data[15:14];
                tr.crc = vif.data[23:16];
                `uvm_info("S0_DRV", $sformatf("Received Control Word: Length=%0d, Dest=%b, Src=%b, CRC=%h", tr.length, tr.dest, tr.src, tr.crc), UVM_NONE);
                tr.data[0] = vif.data;
                tr.keep[0] = vif.keep;
                // Receive data words
                for(int i = 1; i <= (tr.length == 12'h000 ? 4096 : tr.length); i++) begin
                    //wait(vif.ready && vif.valid);
                    wait(vif.valid);
                    @(posedge vif.clk);
                    tr.data[i] = vif.data;
                    tr.keep[i] = vif.keep;
                    if (i == (tr.length == 12'h000 ? 4096 : tr.length)) begin
                        tr.eop = vif.eop;
                    end
                end
                vif.s_ready <= 1'b0;
                // Verify CRC
                if(tr.crc != calculate_crc({8'h00, 8'h00, tr.src, tr.dest, tr.length})) begin
                    `uvm_error("S0_DRV", "CRC Mismatch! Data might be corrupted.");
                end
                `uvm_info("S0_DRV", "Packet Received Successfully", UVM_NONE);
            
                seq_item_port.item_done();
            end
        end
    endtask
endclass

//slave 1
class S1_driver extends uvm_driver#(packet_transaction);
    `uvm_component_utils(S1_driver)

    virtual S1_if vif;
    packet_transaction tr;
    
    function new(string path = "S1_driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual S1_if)::get(this, "", "S1_vif", vif))
            `uvm_error("S1_DRV", "Unable to access the interface S1");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tr);
            if(vif.rst) begin
                `uvm_info("S1_DRV", "System Reset Detected", UVM_NONE);
                @(posedge vif.clk);
            end

            // Wait for valid control word
            @(posedge vif.clk iff (vif.valid && !vif.rst));
                tr.sop = vif.sop;
                tr.eop = vif.eop;
                tr.length = vif.data[11:0];
                tr.data = new[tr.length];
                tr.keep = new[tr.length + 1];
                tr.dest = vif.data[13:12];
                tr.src = vif.data[15:14];
                tr.crc = vif.data[23:16];
                `uvm_info("S1_DRV", $sformatf("Received Control Word: Length=%0d, Dest=%b, Src=%b, CRC=%h", tr.length, tr.dest, tr.src, tr.crc), UVM_NONE);
                
                // Receive data words
                
                for(int i = 0; i < (tr.length == 12'h000 ? 4096 : tr.length); i++) begin
                    vif.ready <= 1'b1; // Ensure ready is asserted before checking valid
                    @(posedge vif.clk iff vif.valid);
                        tr.data[i] = vif.data;
                        tr.keep[i] = vif.keep;
                end

                // Verify CRC
                if(tr.crc != calculate_crc({8'h00, tr.src, tr.dest, tr.length})) begin
                    `uvm_error("S1_DRV", "CRC Mismatch! Data might be corrupted.");
                end
                `uvm_info("S1_DRV", "Packet Received Successfully", UVM_NONE);
            
            seq_item_port.item_done();
        end
    endtask
endclass

//slave 2
class S2_driver extends uvm_driver#(packet_transaction);
    `uvm_component_utils(S2_driver)

    virtual S2_if vif;
    packet_transaction tr;
    
    function new(string path = "S2_driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual S2_if)::get(this, "", "S2_vif", vif))
            `uvm_error("S2_DRV", "Unable to access the interface S2");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tr);
            if(vif.rst) begin
                vif.ready <= 1'b0;
                `uvm_info("S2_DRV", "System Reset Detected", UVM_NONE);
                @(posedge vif.clk);
                vif.ready <= 1'b1;
            end

            // Wait for valid control word
            @(posedge vif.clk iff vif.valid);
                tr.sop = vif.sop;
                tr.eop = vif.eop;
                tr.length = vif.data[11:0];
                tr.data = new[tr.length];
                tr.keep = new[tr.length + 1];
                tr.dest = vif.data[13:12];
                tr.src = vif.data[15:14];
                tr.crc = vif.data[23:16];
                `uvm_info("S2_DRV", $sformatf("Received Control Word: Length=%0d, Dest=%b, Src=%b, CRC=%h", tr.length, tr.dest, tr.src, tr.crc), UVM_NONE);
                
                // Receive data words
                for(int i = 0; i < (tr.length == 12'h000 ? 4096 : tr.length); i++) begin
                    vif.ready <= 1'b1; // Ensure ready is asserted before checking valid
                    @(posedge vif.clk iff vif.valid);
                        tr.data[i] = vif.data;
                        tr.keep[i] = vif.keep;
                end

                // Deassert ready every 100 cycles 
                if (i % 100 == 0) begin
                    vif.ready <= 1'b0;
                    @(posedge vif.clk);
                    vif.ready <= 1'b1;
                end

                // Verify CRC
                if(tr.crc != calculate_crc({8'h00, tr.src, tr.dest, tr.length})) begin
                    `uvm_error("S2_DRV", "CRC Mismatch! Data might be corrupted.");
                end
                `uvm_info("S2_DRV", "Packet Received Successfully", UVM_NONE);
            
            seq_item_port.item_done();
        end
    endtask
endclass