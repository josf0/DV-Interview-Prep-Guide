//transaction

typedef enum bit [1:0] {readd= 0, writed = 1, rstdut = 2} oper_mode;

class packet_transaction extends uvm_sequence_item;

    rand oper_mode op;
    rand logic rst;
    rand logic valid;
    rand logic ready;
    rand logic sop;
    rand logic eop;
    rand logic [31:0] data[];
         logic [3:0] keep[];
    rand logic [11:0] length;
    rand logic [1:0] dest;
    rand logic [1:0] src;
    bit [7:0] crc;
    
    `uvm_object_utils_begin(packet_transaction)
        `uvm_field_int(rst, UVM_ALL_ON)
        `uvm_field_int(valid, UVM_ALL_ON)
        `uvm_field_int(ready, UVM_ALL_ON)
        `uvm_field_int(sop, UVM_ALL_ON)
        `uvm_field_int(eop, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(keep, UVM_ALL_ON)
        `uvm_field_int(length, UVM_ALL_ON)
        `uvm_field_int(dest, UVM_ALL_ON)
        `uvm_field_int(src, UVM_ALL_ON)
        `uvm_field_enum(oper_mode, op, UVM_DEFAULT)
    `uvm_object_utils_end

    constraint valid_dest {
        dest inside {2'b00, 2'b01, 2'b10};
    }

    constraint valid_length {
        length inside {[1:4095]};
    }

    constraint valid_src {
        src inside {2'b00, 2'b01};
    }

    constraint valid_data_size {
        if(length == 12'h000) data.size() == 4096;
        else data.size() == length; 
    }

    constraint valid_keep_size {
        if(length == 12'h000) keep.size() == 4097;
        else keep.size() == (length+1);
    }

    constraint valid_keep {
        foreach (keep[i]) begin
            if(i < (keep.size()-1)) keep[i] == 4'b1111;
            else keep[i] == 4'b0001;
        end
    }
    
    function new(string path = "packet_transaction");
        super.new(path);
    endfunction

    function void compute_crc();
        bit [31:0] control_word = {8'h00, 8'h00, src, dest, length};
        //crc should be kept to 00 while computing the CRC itself
        crc = calculate_crc(control_word);
    endfunction

endclass

class packet_sequence extends uvm_sequence#(packet_transaction);
    `uvm_object_utils(packet_sequence)

    packet_transaction tr;

    function new(string path = "packet_sequence");
        super.new(path);
    endfunction

    virtual task body();
        repeat(15) begin
            tr = packet_transaction::type_id::create("tr");
            start_item(tr);
            assert(tr.randomize());
            tr.compute_crc();
            finish_item(tr);
        end
    endtask
endclass

//master0 driver
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

                //Data transfer
                if(tr.op == writed) begin
                    vif.rst <= 1'b0;
                    vif.valid <= 1'b1;
                    vif.sop <= 1'b1;
                    //send the control word
                    vif.keep <= 4'b1111;
                    @(posedge vif.clk);
                    //send the data
                    for(int i = 0; i <= tr.length ; i++) begin
                        wait((vif.valid && vif.ready) == 1'b1);
                        vif.keep <= tr.keep[i];
                        if(i == 0) begin
                            vif.data <= {8'h00, tr.crc, tr.src, tr.dest, tr.length};
                            vif.sop <= 1'b0; //clear sop after sending the control word
                        end
                        else vif.data <= tr.data[i];
                        if(i == tr.length) begin
                            vif.eop <= 1'b1;    //set eop for last packet
                            vif.keep <= 4'b0001;    
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

//master0 monitor
class M0_mon extends uvm_monitor;
    `uvm_component_utils(M0_mon)

    packet_transaction tr;
    virtual M0_if vif;
    uvm_analysis_port#(packet_transaction) send;

    function new(string path = "M0_mon", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual M0_if)::get(this, "", "vif", vif))
            `uvm_error("M0_MON", "Unable to access the interface");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            if(vif.rst) begin
                tr.op = rstdut;
                `uvm_info("M0_MON", "System Reset Detected", UVM_NONE);
                send.write(tr);
            end

            else begin
                @(posedge vif.sop); //wait for sop
                tr.op = writed;
                tr.valid = vif.valid;
                tr.ready = vif.ready;
                tr.sop = vif.sop;

                for(int i = 0; i < tr.length ; i++) begin
                    @(posedge vif.clk);
                    wait((vif.valid && vif.ready) == 1'b1);
                    tr.keep[i] = vif.keep;
                    if(i == 0) begin
                        tr.length = vif.data[11:0];
                        tr.dest = vif.data[13:12];
                        tr.src = vif.data[15:14];
                        tr.crc = vif.data[23:16];
                    end
                    else tr.data[i-1] = vif.data;
                    if(i == tr.length - 1) tr.eop = vif.eop;
                end
                send.write(tr);
            end
        end
    endtask
endclass

//master1 driver
class M1_driver extends uvm_driver#(packet_transaction);
    `uvm_component_utils(M1_driver)

    virtual M1_if vif1;
    packet_transaction tr;
    
    function new(string path = "M1_driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual M1_if)::get(this, "", "vif", vif1))
            `uvm_error("M1_DRV", "Unable to access the interface M1", UVM_NONE);
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tr);
                //reset
                if(tr.op == rstdut) begin
                    vif1.rst <= 1'b1;
                    vif1.valid <= 1'b0;
                    vif1.ready <= 1'b0;
                    vif1.sop <= 1'b0;
                    vif1.eop <= 1'b0;
                    `uvm_info("M1_DRV", "System Reset detected", UVM_NONE);
                    @(posedge vif1.clk);
                    vif1.rst <= 1'b0;
                end

                //Data transfer
                if(tr.op == writed) begin
                    vif1.rst <= 1'b0;
                    vif1.valid <= 1'b1;
                    vif1.sop <= 1'b1;

                    //send the control word
                    vif1.keep <= 4'b1111;
                    vif1.data <= {8'h00, tr.crc, tr.src, tr.dest, tr.length};
                    @(posedge vif1.clk);
                    vif1.sop <= 1'b0; //clear sop after sending the control word
                    //send the data
                    for(int i = 0; i < tr.length ; i++) begin
                        wait((vif1.valid && vif1.ready) == 1'b1);
                        vif1.keep <= tr.keep[i];
                        vif1.data <= tr.data[i];

                        if(i == tr.length -1) begin
                            vif1.eop <= 1'b1;    //set eop for last packet
                            vif1.keep <= 4'b0001;    
                        end
                        @(posedge vif1.clk);
                    end
                    //specify eop
                    vif1.eop <= 1'b0;
                    vif1.valid <= 1'b0;
                    `uvm_info("M1_DRV", "Data transfer successful", UVM_NONE);
                    @(posedge vif1.clk);
                end
            seq_item_port.item_done();  
        end
       
    endtask
endclass
       
//master1 monitor
class M1_mon extends uvm_monitor;
    `uvm_component_utils(M1_mon)

    packet_transaction tr;
    virtual M1_if vif1;
    uvm_analysis_port#(packet_transaction) send1;

    function new(string path = "M1_mon", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual M1_if)::get(this, "", "vif", vif1))
            `uvm_error("M0_MON", "Unable to access the interface");
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif1.clk);
            if(vif1.rst) begin
                tr.op = rstdut;
                `uvm_info("M0_MON", "System Reset Detected", UVM_NONE);
                send1.write(tr);
            end

            else begin
                @(posedge vif1.sop); //wait for sop
                tr.op = writed;
                tr.valid = vif1.valid;
                tr.ready = vif1.ready;
                tr.sop = vif1.sop;

                int pkt_length;
                tr.length = vif1.data[11:0];
                tr.dest = vif1.data[13:12];
                tr.src = vif1.data[15:14];
                tr.crc = vif1.data[23:16];
                pkt_length = (tr.length == 12'h000) ? 4096: tr.length;
                tr.data = new[pkt_length];
                tr.keep = new[pkt_length + 1];

                for(int i = 0; i < pkt_length ; i++) begin
                    @(posedge vif1.clk);
                    wait((vif1.valid && vif1.ready) == 1'b1);
                    tr.keep[i] = vif1.keep;
                    tr.data[i] = vif1.data;
                    if(i == pkt_length - 1) tr.eop = vif1.eop;
                end
                send1.write(tr);
            end
        end
    endtask
endclass

//slave0 driver
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

                else begin
                    wait(sif.valid == 1'b1);
                    @(posedge sif.sop);
                    tr.ready = 1'b1;
                    tr.sop = sif.sop;
                    tr.eop = sif.eop;
                    tr.valid = sif.valid;
                    for(int i = 0; i <= tr.length; i++) begin
                        wait(vif.valid && vif.ready == 1'b1);
                        tr.keep[i] = vif.keep;
                        if( i == 0) tr.data[i] <= {8'h00, sif.crc, sif.src, sif.dest, sif.length};
                        else tr.data[i] = sif.data;
                        @(posedge sif.clk);
                    end
                end
            seq_item_port.item_done();
        end
    endtask
endclass

//slave1 driver
class S1_driver extends uvm_driver#(packet_transaction);
    `uvm_component_utils(S1_driver)

    packet_transaction tr;
    virtual S1_if sif1;

    function new(string path = "S1_driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual S1_if)::get(this, "", "sif", sif1))
            `uvm_error("S0_DRV", "Unable to access the interface");
    endfunction

    virtual task run_phase(uvm_phase);
        forever begin
            seq_item_port.get_next_item(tr);
                if(sif1.rst) begin
                    tr.valid = 1'b0;
                    tr.data = 0;
                    tr.sop = 1'b0;
                    tr.eop = 1'b0;
                    @(posedge sif1.clk);
                end

                else begin
                    wait(sif1.valid == 1'b1);
                    @(posedge sif1.sop);
                    tr.ready = 1'b1;
                    tr.sop = sif1.sop;
                    tr.eop = sif1.eop;
                    tr.valid = sif1.valid;
                    for(int i = 0; i <= tr.length; i++) begin
                        wait(sif1.valid && sif1.ready == 1'b1);
                        tr.keep[i] = sif1.keep;
                        if( i == 0) tr.data[i] <= {8'h00, sif1.crc, sif1.src, sif1.dest, sif1.length};
                        else tr.data[i] = sif1.data;
                        @(posedge sif1.clk);
                    end
                end
            seq_item_port.item_done();
        end
    endtask
endclass

