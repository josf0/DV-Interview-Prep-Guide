
//M0 Driver
class M0_driver extends uvm_driver#(packet_transaction);
    `uvm_component_utils(M0_driver)

    virtual M_if vif;
    packet_transaction tr;
    
    function new(string path = "M0_driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual M_if)::get(this, "", "m0_if", vif))
            `uvm_error("M0_DRV", "Unable to access the interface M0");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tr);
                vif.rst   <= 1'b1;
                vif.valid <= 1'b0;
                vif.sop   <= 1'b0;
                vif.eop   <= 1'b0;
                vif.data <= 32'h00000000;
                vif.keep <= 4'b0000;
                `uvm_info("M0_DRV", "System Reset detected", UVM_NONE);
                @(posedge vif.clk);
                vif.rst <= 1'b0;
                @(posedge vif.clk);

            // Handle Data Transfer
                vif.valid <= 1'b1;
                vif.sop   <= 1'b1;  
                tr.compute_crc();
                tr.src = 2'b00;
                vif.eop <= 1'b0;
                vif.data  <= {8'h00, tr.crc, tr.src, tr.dest, tr.length}; 
                vif.keep  <= 4'b1111;
                // wait for DUT to be ready 
                wait(vif.ready);
                @(posedge vif.clock);
                vif.sop   <= 1'b0;  
                // Transfer Data Words (remove last element as keep is diff)
                for(int i = 0; i < (tr.length == 12'h000 ? 4096 : (tr.length)); i++) begin
                    vif.data  <= tr.data[i];
                    //for handling last element
                    if (i == (tr.length == 12'h000 ? 4095 : tr.length-1)) begin
                        vif.keep <= 4'b0001;
                        vif.eop <= 1'b1;
                    end     
                    else begin
                        vif.keep <= 4'b1111;
                    end               
                    //wait for DUT to be ready 
                    wait(vif.ready);
                    @(posedge vif.clk);   
                end
                `uvm_info("M0_DRV", "Data transfer successful", UVM_NONE);
                // Clear signals after last transfer
                vif.eop   <= 1'b0;
                vif.valid <= 1'b0;
            seq_item_port.item_done();  
        end
    endtask
    
endclass

//M1 Driver
class M1_driver extends uvm_driver#(packet_transaction);
    `uvm_component_utils(M1_driver)

    virtual M1_if vif;
    packet_transaction tr;
    
    function new(string path = "M1_driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual M1_if)::get(this, "", "M1_vif", vif))
            `uvm_error("M1_DRV", "Unable to access the interface M1");
    endfunction

    task resetdut();
        vif.rst   <= 1'b1;
        vif.valid <= 1'b0;
        vif.sop   <= 1'b0;
        vif.eop   <= 1'b0;
        vif.data <= 32'h00000000;
        vif.keep <= 4'b0000;
        `uvm_info("M1_DRV", "System Reset detected", UVM_NONE);
        @(posedge vif.clk);
        vif.rst <= 1'b0;
        @(posedge vif.clk);
    endtask

    virtual task run_phase(uvm_phase phase);
        // resetdut();
        forever begin
            seq_item_port.get_next_item(tr);
                @(posedge vif.clk);
                vif.rst   <= 1'b1;
                vif.valid <= 1'b0;
                vif.sop   <= 1'b0;
                vif.eop   <= 1'b0;
                vif.data <= 32'h00000000;
                vif.keep <= 4'b0000;
                `uvm_info("M1_DRV", "System Reset detected", UVM_NONE);
                @(posedge vif.clk);
                vif.rst <= 1'b0;
                @(posedge vif.clk);

            // Handle Data Transfer
                vif.valid <= 1'b1;  
                vif.sop   <= 1'b1;  
                tr.compute_crc();
                tr.src = 2'b00;
                vif.eop <= 1'b0;
                vif.data  <= {8'h00, tr.crc, tr.src, tr.dest, tr.length}; 
                vif.keep  <= 4'b1111;
                wait(vif.ready == 1'b1); 
                @(posedge vif.clock);
                // Deassert sop immediately after first transfer
                vif.sop   <= 1'b0;  
                // Transfer Data Words (remove last element as keep is diff)
                for(int i = 0; i < (tr.length == 12'h000 ? 4096 : (tr.length)); i++) begin
                    vif.data  <= tr.data[i];
                    vif.keep  <= tr.keep[i];
                    //for handling last element
                    if (i == (tr.length == 12'h000 ? 4096 : tr.length)) begin
                        vif.keep <= 4'b0001;
                        vif.eop <= 1'b1;
                    end                    
                    wait(vif.ready == 1'b1); 
                    @(posedge vif.clk);   
                end
                `uvm_info("M1_DRV", "Data transfer successful", UVM_NONE);
                // Clear signals after last transfer
                vif.eop   <= 1'b0;
                vif.valid <= 1'b0;
            seq_item_port.item_done();  
        end
    endtask
    
endclass
