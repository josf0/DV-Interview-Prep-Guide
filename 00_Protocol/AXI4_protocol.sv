//Complete variations of queue in AXI4
//awlength will define the number of transfer in a burst. if it is 7 there will be 8 transfers
//awsize will define the number of bytes in a transfer. if it is 2 then there will be 4 bytes per transfer (32-bit).
//awburst - 0, 1, 2 defines, fixed, increment and wrap mode



//driver for AXI4 with length, size and burst
class axi_driver extends uvm_driver#(axi_transaction);
    `uvm_component_utils(axi_driver)
  
    virtual axi_if vif;  // AXI Virtual Interface
  
    function new(string name = "axi_driver", uvm_component parent);
      super.new(name, parent);
    endfunction
  
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual axi_if)::get(this, "", "vif", vif))
        `uvm_fatal("AXI_DRIVER", "Virtual interface not set")
    endfunction
  
    virtual task run_phase(uvm_phase phase);
        packet_transaction tr;
    
        forever begin
            seq_item_port.get_next_item(tr);  // Get transaction from sequencer
    
            if(tr.op == WRITE) begin
                // **Write Address Channel (AW)**
                vif.awvalid <= 1'b1;
                vif.awaddr  <= tr.awaddr; //32'h1000_000
                vif.awlen   <= tr.awlen;  // 7, AXI3: 1-16, AXI4: 1-256
                vif.awsize  <= tr.awsize; //2 - 4 bytes per transfer
                vif.awburst <= tr.awburst; //1 - increment mode 
                wait(vif.awready);
                vif.awvalid <= 1'b0;  // De assert after handshake
    
                // **Write Data Channel (W)**
                for(int i = 0; i < tr.burst_length; i++) begin
                    vif.wvalid <= 1'b1;
                    vif.wdata  <= tr.wdata[i];
                    vif.wstrb  <= tr.wstrb[i];
                    vif.wlast  <= (i == tr.burst_length -1) ? 1'b1 : 1'b0;
                    wait(vif.wready);
                    @(posedge vif.clk);
                end
                vif.wvalid <= 1'b0;  // Deassert after last beat
    
                // **Write Response Channel (B)**
                vif.bready <= 1'b1;
                wait(vif.bvalid);
                tr.bresp = vif.bresp;  // Capture response (DO NOT drive bresp)
                vif.bready <= 1'b0;
            end
            
            else if(tr.op == READ) begin
                // **Read Address Channel (AR)**
                vif.arvalid <= 1'b1;
                vif.araddr  <= tr.araddr;
                vif.arlen   <= tr.arburst_len - 1;
                vif.arsize  <= tr.arsize;
                vif.arburst <= tr.arburst;
                wait(vif.arready);
                vif.arvalid <= 1'b0;  // Deassert after handshake
    
                // **Read Data Channel (R)**
                vif.rready <= 1'b1;
                for(int i = 0; i < tr.arburst_len; i++) begin
                    wait(vif.rvalid);
                    tr.rdata.push_back(vif.rdata);
                    tr.rresp.push_back(vif.rresp);
                    if(vif.rlast) break;
                    @(posedge vif.clk);
                end
                vif.rready <= 1'b0;  // Deassert after read completion
            end
    
            seq_item_port.item_done();  // Mark transaction as completed
        end
    endtask
endclass

//what about the sequence that assigns value to queue
class write_seq extends uvm_sequence#(packet_transaction);
    `uvm_object_utils(write_seq)

    //new constructor

    virtual task body();
        packet_transaction tr;
        tr = packet_transaction::type_id::create("tr");
        tr.op = "WRITE";
        tr.awaddr = 32'h1000_0000;
        tr.awlen = 7;
        tr.awsize = 2; //4 bytes per transfer
        tr.awburst = 2'b01; //increment mode

        //fill wdata queue dynamically
        for(int i = 0; i < tr.awlen + 1 ; i++) begin
            tr.wdata.push_back($urandom_range(0, 32'hFFFF_FFFF));
            tr.wstrb.push_back(4'hF); //full byte enable
            /*
                if (tr.awsize == 2) begin
                        // Full 32-bit word transfer — all bytes valid
                        tr.wstrb.push_back(4'b1111);
                    
                    end else if (tr.awsize == 1) begin
                        // Half-word (16-bit) transfer — alignment check
                        if (tr.awaddr[1] == 1'b0) begin
                            tr.wstrb.push_back(4'b0011);  // Lower 16 bits valid
                        end else begin
                            tr.wstrb.push_back(4'b1100);  // Upper 16 bits valid
                        end
                    
                    end else if (tr.awsize == 0) begin
                        // Byte transfer — check `awaddr[1:0]` for correct byte lane
                        case (tr.awaddr[1:0])
                            2'b00: tr.wstrb.push_back(4'b0001); // Byte 0
                            2'b01: tr.wstrb.push_back(4'b0010); // Byte 1
                            2'b10: tr.wstrb.push_back(4'b0100); // Byte 2
                            2'b11: tr.wstrb.push_back(4'b1000); // Byte 3
                        endcase
                end
            */
        end

        start_item(tr);
        //assert (tr.randomize())
        finish_item(tr);
    endtask
endclass

//Monitor
class axi4_monitor extends uvm_monitor;
    `uvm_component_utils(axi4_monitor)

    virtual axi4_interface vif;  // AXI Virtual Interface
    uvm_analysis_port #(packet_transaction) analysis_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_port = new("analysis_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi4_interface)::get(this, "", "vif", vif))
            `uvm_fatal("AXI_MONITOR", "Virtual interface not set")
    endfunction

    virtual task run_phase(uvm_phase phase);
        packet_transaction tr;

        forever begin
            tr = packet_transaction::type_id::create("tr");

            // ================================
            // WRITE TRANSACTION (AW + W + B)
            // ================================
            if (vif.awvalid && vif.awready) begin
                tr.op       = WRITE;
                tr.awaddr   = vif.awaddr;
                tr.awlen    = vif.awlen;
                tr.awsize   = vif.awsize;
                tr.awburst  = vif.awburst;

                // Capturing Write Data Channel
                for(int i = 0; i <= tr.awlen; i++) begin
                    wait(vif.wvalid && vif.wready);
                    @(posedge vif.clk);
                    tr.wdata.push_back(vif.wdata);   // Store 32-bit data
                    tr.wstrb.push_back(vif.wstrb);   // Capture wstrb
                    if (vif.wlast) break;
                end

                // Capturing Write Response Channel
                wait(vif.bvalid && vif.bready);
                tr.bresp = vif.bresp;

                // Send captured transaction to scoreboard
                analysis_port.write(tr);
            end

            // ================================
            // READ TRANSACTION (AR + R)
            // ================================
            if (vif.arvalid && vif.arready) begin
                tr.op       = READ;
                tr.araddr   = vif.araddr;
                tr.arlen    = vif.arlen;
                tr.arsize   = vif.arsize;
                tr.arburst  = vif.arburst;

                // Capturing Read Data Channel
                 // Collect read data beats
                for (int i = 0; i <= tr.len; i++) begin
                    wait(vif.rvalid && vif.rready);
                    @(posedge vif.clk);
                    tr.rdata.push_back(vif.rdata);
                    tr.rresp.push_back(vif.rresp);
                    if (vif.rlast) break;
                end

                // Send captured transaction to scoreboard
                analysis_port.write(tr);
            end
        end
    endtask
endclass

//assume queue in transaction is only 1 byte
//Then implement the transaction, sequence and driver
class packet_transaction extends uvm_sequence_item;
    `uvm_object_utils(packet_transaction)

    rand bit [31:0] addr;
    rand bit [7:0] len;
    rand bit [2:0] size;
    rand bit [1:0] burst; //FIXED, INCR, WRAP
    rand bit [7:0] wdata[$];
    rand bit [0:0] wstrb[$];
    bit [7:0] rdata[$];
    bit [1:0] rresp[$];
    rand bit bresp;
    rand bit op;

    //function new
    function new(string path = "packet_transaction");
        super.new(path);
    endfunction
endclass

class write_seq extends uvm_sequence#(packet_transaction);
    `uvm_object_utils(write_seq)

    //funciton new

    virtual task body();
        packet_transaction tr;
        tr = packet_transaction::type_id::create("tr");
        tr.op = "WRITE";
        tr.addr = 32'h1000_0000;
        tr.len = 7; //8 transfers per burst
        tr.size = 2; //4 bytes per transfer
        tr.burst = 1; //increment mode

        //fill in the data to queue
        for(int i = 0; i < (tr.len + 1); i++) begin
            tr.wdata.push_back($urandom_range(0, 8'hFF));
            tr.wstrb.push_back(1'b1);
        end

        start_item(tr);
        finish_item(tr);
    endtask
endclass

virtual task run_phase(uvm_phase phase);
    packet_transaction tr;
    forever begin
        seq_item_port.get_next_item(tr);
        if(tr.op == WRITE) begin
            //write address channel
            vif.awvalid <= 1'b1;
            vif.awaddr <= tr.addr;
            vif.awlen <= tr.len; //7 - 8 transfers per burst
            vif.awsize <= tr.size; //2 - 4 bytes per transfer
            vif.awburst <= tr.burst; //1 - Increment mode
            wait(vif.awready);
            vif.awvalid <= 1'b0;

            //write data channel
            vif.wvalid <= 1'b1;
            for(int i = 0; i + 3 < tr.wdata.size(); i = i + 4) begin
                //two temporary variables for combined data and strobe
                bit [31:0] combined_data;
                bit [3:0] combined_strobe;

                combined_data = {tr.wdata[i], tr.wdata[i+1], tr.wdata[i+2], tr.wdata[i+3]};
                combined_strobe = {tr.wstrb[i], tr.wstrb[i+1], tr.wstrb[i+2], tr.wstrb[i+3]};

                vif.wdata <= combined_data;
                vif.wstrb <= combined_strobe;
                vif.wlast <= (i == tr.wdata.size() - 4) ? 1'b1: 1'b0;
                wait(vif.wready);
                @(posedge vif.clk);
            end
            vif.wvalid <= 1'b0;

            //write response channel
            vif.bready <= 1'b1;
            wait(vif.bvalid);
            tr.bresp = vif.bresp;
            @(negedge vif.bvalid);
            vif.bready <= 1'b0;
        end

        else if(tr.op == READ) begin
            //Read Address channel
            vif.arvalid <= 1'b1;
            vif.araddr <= tr.addr;
            vif.arlen <= tr.len;
            vif.arsize <= tr.size;
            vif.arburst <= tr.burst;
            wait(vif.arready);
            vif.arvalid <= 1'b0;

            //read data channel
            vif.rready <= 1'b1;
            for(int i = 0; i < tr.len + 1; i++) begin
                wait(vif.rvalid);
                tr.rdata.push_back(vif.rdata[7:0]);
                tr.rdata.push_back(vif.rdata[15:8]);
                tr.rdata.push_back(vif.rdata[23:16]);
                tr.rdata.push_back(vif.rdata[31:24]);

                //store rresp for 32 bit as slave sends only one rresp
                tr.rresp.push_back(vif.rresp);

                if(vif.rlast) break;
                @(posedge vif.clk);
            end
            vif.rready <= 1'b0;
        end
        else if(tr.op == RESET) begin
            vif.awvalid <= 1'b0;
            vif.wvalid <= 1'b0;
            vif.bready <= 1'b0;
            vif.arvalid <= 1'b0;
            vif.rready <= 1'b0;
            @(posedge vif.clk);
        end
        seq_item_port.item_done();
    end
endtask

//with same 1 byte queue implement all the logic in driver instead of sequence

virtual task run_phase(uvm_phase phase);
    packet_transaction tr;

    forever begin
        seq_item_port.get_next_item(tr);  // ✅ Get transaction from sequencer

        // ✅ Dynamically generate transaction fields
        tr.addr = $urandom_range(32'h1000_0000, 32'h1FFF_FFFF);
        tr.burst_length = $urandom_range(0, 7);  // Random burst length (1 to 8 beats)
        tr.size = 0;  // ✅ 1 byte per transfer (AWSIZE = 0)
        tr.burst_type = 2'b01; // ✅ INCR burst
        tr.op = $urandom_range(0, 1); // ✅ Randomly decide Read (0) or Write (1)

        if (tr.op == WRITE) begin
            // **Write Address Channel (AW)**
            vif.awvalid <= 1'b1;
            vif.awaddr  <= tr.addr;
            vif.awlen   <= tr.burst_length - 1;
            vif.awsize  <= tr.size;
            vif.awburst <= tr.burst_type;

            wait(vif.awready);
            vif.awvalid <= 1'b0;  // ✅ Deassert after handshake

            // **Write Data Channel (W)**
            for(int i = 0; i < (tr.burst_length + 1) * 4; i++) begin
                bit [7:0] byte_data = $urandom_range(0, 8'hFF);
                tr.wdata.push_back(byte_data);  // ✅ Store 1-byte data
                tr.wstrb.push_back(1'b1); // ✅ Enable only 1 byte per location
            end

            for(int i = 0; i < tr.wdata.size(); i += 4) begin
                vif.wvalid <= 1'b1;

                // ✅ Combine 4 bytes into 32-bit AXI word
                bit [31:0] combined_data;
                bit [3:0]  combined_strobe;

                combined_data = {tr.wdata[i], tr.wdata[i+1], tr.wdata[i+2], tr.wdata[i+3]};
                combined_strobe = {tr.wstrb[i], tr.wstrb[i+1], tr.wstrb[i+2], tr.wstrb[i+3]};

                vif.wdata  <= combined_data;
                vif.wstrb  <= combined_strobe;
                vif.wlast  <= (i >= tr.wdata.size() - 4) ? 1'b1 : 1'b0;

                wait(vif.wready);
                @(posedge vif.clk);
            end
            vif.wvalid <= 1'b0;  // ✅ Deassert after last beat

            // **Write Response Channel (B)**
            vif.bready <= 1'b1;
            wait(vif.bvalid);
            tr.bresp = vif.bresp;  // ✅ Capture response
            vif.bready <= 1'b0;
        end

        else if(tr.op == READ) begin
            // **Read Address Channel (AR)**
            vif.arvalid <= 1'b1;
            vif.araddr  <= tr.addr;
            vif.arlen   <= tr.burst_length - 1;
            vif.arsize  <= tr.size;
            vif.arburst <= tr.burst_type;

            wait(vif.arready);
            vif.arvalid <= 1'b0;  // ✅ Deassert after handshake

            // **Read Data Channel (R)**
            vif.rready <= 1'b1;
            for(int i = 0; i < (tr.burst_length + 1); i++) begin
                wait(vif.rvalid);

                // ✅ Extract 1-byte data from 32-bit `rdata`
                tr.rdata.push_back(vif.rdata[7:0]);
                tr.rdata.push_back(vif.rdata[15:8]);
                tr.rdata.push_back(vif.rdata[23:16]);
                tr.rdata.push_back(vif.rdata[31:24]);

                // ✅ Store `rresp` for each byte
                tr.rresp.push_back(vif.rresp);
                tr.rresp.push_back(vif.rresp);
                tr.rresp.push_back(vif.rresp);
                tr.rresp.push_back(vif.rresp);

                if (vif.rlast) break;
                @(posedge vif.clk);
            end
            vif.rready <= 1'b0;  // ✅ Deassert after last read
        end

        seq_item_port.item_done();  // ✅ Mark transaction as completed
    end
endtask