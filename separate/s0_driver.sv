class S0_driver extends uvm_driver#(packet_transaction);
    `uvm_component_utils(S0_driver)

    packet_transaction tr;
    virtual S0_if sif;

    function new(string path = "S0_driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual S0_if)::get(this, "", "sif", sif))
            `uvm_error("S0_DRV", "Unable to access the interface");
    endfunction

    virtual task run_phase(uvm_phase);
        forever begin
            seq_item_port.get_next_item(tr);
                if(sif.rst) begin
                    tr.valid = 1'b0;
                    tr.data = 0;
                    tr.sop = 1'b0;
                    tr.eop = 1'b0;
                end

                wait(sif.valid == 1);

                sif.ready <= 1'b1;

                if(sif.sop) begin
                    tr.sop = sif.sop;
                    tr.eop = sif.eop;
                    tr.valid = sif.valid;
                    tr.keep[0] = sif.keep;
                    @(posedge sif.clk);
                end
                int i = 0;
                while(sif.valid && !sif.eop) begin
                    tr.data[i] = sif.data;
                    tr.keep[i+1] = sif.keep;
                    i++;
                    @(posedge sif.clk);
                end

                if(sif.eop) begin
                    tr.eop = sif.eop;
                    tr.data[i] = sif.data;
                    tr.keep[i+1] = sif.keep;
                    @(posedge sif.clk);
                end

                sif.ready <= 1'b0;
            seq_item_port.item_done();
        end
    endtask
endclass
