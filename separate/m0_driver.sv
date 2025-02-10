class M0_driver extends uvm_driver#(packet_transaction);
    `uvm_component_utils(M0_driver)

    virtual M0_if vif;
    packet_transaction tr;
    
    function new(string path = "M0_driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual M0_if)::get(this, "", "vif", vif))
            `uvm_error("M0_DRV", "Unable to access the interface M0", UVM_NONE);
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tr);
                //reset
                if(tr.op == rstdut) begin
                    vif.rst <= 1'b1;
                    vif.valid <= 1'b0;
                    vif.ready <= 1'b0;
                    vif.sop <= 1'b0;
                    vif.eop <= 1'b0;
                    `uvm_info("MO_DRV", "System Reset detected", UVM_NONE);
                    @(posedge vif.clk);
                    vif.rst <= 1'b0;
                end

                //drive Data transfer
                if(tr.op == drived) begin
                    vif.rst <= 1'b0;
                    vif.valid <= 1'b1;
                    vif.sop <= 1'b1;
                    //send the control word
                    vif.keep <= 4'b1111;
                    @(posedge vif.clk);
                    //send the data
                    for(int i = 0; i <= tr.length + 1 ; i++) begin
                        wait((vif.valid && vif.ready) == 1'b1);
                        vif.keep <= tr.keep[i];
                        if(i == 0) begin
                            vif.data <= {8'h00, tr.crc, tr.src, tr.dest, tr.length};
                            vif.sop <= 1'b1; //clear sop after sending the control word
                            vif.keep <= 4'b1111;
                        end
                        else if(i == tr.length + 1) begin
                            vif.eop <= 1'b1;    //set eop for last packet
                            vif.keep <= 4'b0001;    
                        end
                        else begin
                            vif.data <= tr.data[i - 1];
                            vif.sop <= 1'b0;
                            vif.keep <= 4'b1111;
                        end
                        @(posedge vif.clk);
                    end
                    //specify eop
                    vif.eop <= 1'b0;
                    vif.valid <= 1'b0;
                    `uvm_info("M0_DRV", "Data transfer successful", UVM_NONE);
                    @(posedge vif.clk);
                end
            seq_item_port.item_done();  
        end
       
    endtask
endclass