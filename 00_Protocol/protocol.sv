//driver for axi_lite
virtual task run_phase(uvm_phase phase);
    axi_lite_transaction tr;
  
    forever begin
        seq_item_port.get_next_item(tr);
        //write transaction
        if(tr.op == write) begin
        //write address channel
        vif.awaddr <= tr.awaddr;
        vif.awvalid <= 1;
        wait(vif.awready);
        vif.awvalid <= 0;
  
        //write data channel
        vif.wdata <= tr.wdata;
        vif.wstrb <= tr.wstrb;
        vif.wvalid <= 1'b1;
        wait(vif.wready);
        vif.wvalid <= 1'b0;
  
        //write response channel
        vif.bready <= 1;
        wait(vif.bvalid);
        vif.bresp <= tr.bresp;
        vif.ready <= 0;
        end
  
        else begin
            //read address channel
            vif.araddr <= tr.araddr;
            vif.arvalid <= 1;
            wait(vif.arready);
            vif.arvalid <= 0;
  
            //read data channel
            vif.rready <= 1'b1;
            wait(vif.rvalid);
            tr.rdata = vif.rdata;
            wait(!vif.rvalid);
            vif.rready <= 1'b0;
        end
        seq_item_port.item_done();
    end
endtask

//monitor for axi
class axi_lite_monitor extends uvm_monitor;
    `uvm_component_utils(axi_lite_monitor)
  
    virtual axi_lite_if vif; // Virtual interface
    uvm_analysis_port#(axi_lite_transaction) mon_ap; // Analysis port to send transactions
  
    function new(string name = "axi_lite_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction
  
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual axi_lite_if)::get(this, "", "vif", vif))
            `uvm_fatal("axi_lite_monitor", "Virtual interface not set!")
  
        mon_ap = new("mon_ap", this);
    endfunction
  
    virtual task run_phase(uvm_phase phase);
        axi_lite_transaction tr;
  
        forever begin
            tr = axi_lite_transaction::type_id::create("tr");
  
            // Monitor Write Transaction
            if (vif.awvalid) begin
                // Capture write address channel
                tr.awaddr = vif.awaddr;
                wait(vif.awready);
                `uvm_info("axi_lite_monitor", $sformatf("Captured Write Address: 0x%0X", tr.awaddr), UVM_MEDIUM)
  
                // Capture write data channel
                wait(vif.wvalid);
                tr.wdata = vif.wdata;
                tr.wstrb = vif.wstrb;
                wait(vif.wready);
                `uvm_info("axi_lite_monitor", $sformatf("Captured Write Data: 0x%0X, WSTRB: 0x%0X", tr.wdata, tr.wstrb), UVM_MEDIUM)
  
                // Capture write response channel
                wait(vif.bvalid);
                tr.ack = vif.bresp;
                wait(!vif.bvalid);
                `uvm_info("axi_lite_monitor", "Captured Write Response", UVM_MEDIUM)
            end
  
            // Monitor Read Transaction
            else if (vif.arvalid) begin
                // Capture read address channel
                tr.araddr = vif.araddr;
                wait(vif.arready);
                `uvm_info("axi_lite_monitor", $sformatf("Captured Read Address: 0x%0X", tr.araddr), UVM_MEDIUM)
  
                // Capture read data channel
                wait(vif.rvalid);
                tr.rdata = vif.rdata;
                tr.rresp = vif.rresp;
                wait(!vif.rvalid);
                `uvm_info("axi_lite_monitor", $sformatf("Captured Read Data: 0x%0X, Response: 0x%0X", tr.rdata, tr.rresp), UVM_MEDIUM)
            end
  
            mon_ap.write(tr);
        end
    endtask
endclass

///////////////////////////////////////////////////////////////

//I2C driver
class I2c_driver extends uvm_driver#(packet_transaction);
    virtual task run_phase(uvm_phase phase);
      forever begin
          seq_item_port.get_next_item(tr);
              start_condition();
              send_byte({tr.addr, tr.is_read});//7 bit address, 1 read/write bit
              tr.ack = recieve_ack();
  
              if(is_read) begin
                  read_data(tr);
              end 
              else write_data(tr);
  
              stop_condition();
          seq_item_port.item_done();
      end
    endtask
  
    task start_condition();
      vif.sda <= 1;
      vif.scl <= 1;
      #5;
      vif.sda <= 0; //while scl is high
      #5;
      vif.scl <= 1;
    endtask
  
    task send_byte([7:0] data);
      for(int i = 7; i >= 0; i--) begin
          vif.sda <= tr.data[i];
          #5;
          vif.scl <= 1;
          #5;
          vif.scl <= 0;
      end
    endtask
  
    function bit receive_ack();
      bit ack = !vif.sda;
      return ack;
    endfunction
  
    task read_data(packet_transaction tr);
      bit [7:0] data_byte;
      for(int i = 7; i >= 0; i--) begin
          #5;
          vif.scl <= 1;
          data_byte[i] = vif.sda;
          #5;
          vif.scl <= 0;
      end
      tr.data.push_back(data_byte);
  
      vif.sda <= tr.ack ? 1: 0;
      if(tr.ack == 0) break;
    endtask
  
    task write_data(packet_transaction tr);
      foreach(tr.data[i]) begin
          vif.sda <= tr.data[i];
          #5;
          vif.scl <= 1;
          #5;
          vif.scl <= 0;
      end
      tr.ack = !vif.sda;
      if(tr.ack == 0) `uvm_info("DRV", "STOP");
    endtask
  
    task stop_condition();
      #5;
      vif.scl <= 1;
      #5;
      vif.sda <= 1;
    endtask
endclass
  
//I2C monitor
class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)
  
    virtual i2c_if vif; // Virtual interface
    uvm_analysis_port#(i2c_transaction) mon_ap; // Analysis port to send transactions
  
    function new(string name = "i2c_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction
  
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual i2c_if)::get(this, "", "vif", vif))
            `uvm_fatal("i2c_monitor", "Virtual interface not set!")
  
        mon_ap = new("mon_ap", this);
    endfunction
  
    virtual task run_phase(uvm_phase phase);
        forever begin
            i2c_transaction tr;
            tr = i2c_transaction::type_id::create("tr");
  
            wait_for_start();
            tr.addr = capture_byte();
            tr.is_read = tr.addr[0]; // Extract R/W bit
            tr.addr = tr.addr >> 1;  // Extract 7-bit address
            tr.ack = capture_ack();
  
            if (tr.is_read) begin
                capture_read_data(tr);
            end else begin
                capture_write_data(tr);
            end
  
            wait_for_stop();
            mon_ap.write(tr);
        end
    endtask
  
    // Wait for START condition (SDA goes LOW while SCL is HIGH)
    task wait_for_start();
        wait (vif.sda === 1'b1); // Ensure SDA is initially high
        @(posedge vif.scl);
        wait (vif.sda === 1'b0); // Detect falling edge of SDA while SCL is HIGH
        `uvm_info("i2c_monitor", "START condition detected", UVM_MEDIUM)
    endtask
  
    // Wait for STOP condition (SDA goes HIGH while SCL is HIGH)
    task wait_for_stop();
        @(posedge vif.scl);
        wait (vif.sda === 1'b1); // Detect rising edge of SDA while SCL is HIGH
        `uvm_info("i2c_monitor", "STOP condition detected", UVM_MEDIUM)
    endtask
  
    // Capture a single byte (8 bits)
    function bit [7:0] capture_byte();
        bit [7:0] data;
        for (int i = 7; i >= 0; i--) begin
            @(posedge vif.scl);
            data[i] = vif.sda; // Sample bit on clock edge
        end
        `uvm_info("i2c_monitor", $sformatf("Captured Byte: 0x%02X", data), UVM_MEDIUM)
        return data;
    endfunction
  
    // Capture ACK/NACK from slave
    function bit capture_ack();
        @(posedge vif.scl);
        bit ack = !vif.sda; // ACK = 0, NACK = 1
        `uvm_info("i2c_monitor", $sformatf("Captured ACK: %0d", ack), UVM_MEDIUM)
        return ack;
    endfunction
  
    // Capture multiple data bytes for a write transaction
    task capture_write_data(i2c_transaction tr);
        while (1) begin
            bit [7:0] data_byte = capture_byte();
            tr.data.push_back(data_byte);
            tr.ack = capture_ack();
            if (tr.ack == 0) begin
                `uvm_info("i2c_monitor", "NACK received, stopping capture", UVM_MEDIUM)
                break;
            end
        end
    endtask
  
    // Capture multiple data bytes for a read transaction
    task capture_read_data(i2c_transaction tr);
        while (1) begin
            bit [7:0] data_byte = capture_byte();
            tr.data.push_back(data_byte);
  
            // Monitor expects the master to send ACK/NACK
            @(posedge vif.scl);
            tr.ack = !vif.sda; // Master sends ACK (0) or NACK (1)
  
            `uvm_info("i2c_monitor", $sformatf("Captured Read Byte: 0x%02X, ACK: %0d", data_byte, tr.ack), UVM_MEDIUM)
  
            if (tr.ack == 0) break; // Stop if NACK received
        end
    endtask
endclass


//APB Driver
class apb_ram_driver extends uvm_driver#(packet_transaction);
    `uvm_component_utils(apb_ram_driver)

    virtual apb_ram_if vif;
    packet_transaction tr;

    function new(string name = "apb_ram_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(uvm_phase phase);
        tr = packet_transaction::type_id::create("tr");
        if(!uvm_config_db#(virtual apb_ram_if)::get(this, "", "vif", vif))
            `uvm_error("DRV", "Virtual interface not found")
    endfunction

    task run_phase(uvm_phase);
        resetdut();
        forever begin
            seq_item_port.get_next_item(tr);
            drive_transaction(tr);
            seq_item_port.item_done();
        end
    endtask

    task resetdut();
        vif.presetn <= 1'b0;
        vif.paddr <= '0;
        vif.pwdata <= '0;
        vif.psel <= '0;
        vif.penable <= '0;
        @(posedge vif.clk);
        vif.presetn <= 1;
    endtask

    task drive_transaction(packet_transaction tr);
        @(posedge vif.clk);
        //setup mode
        vif.psel <= 1;
        vif.pwrite <= tr.pwrite;
        vif.paddr <= tr.paddr;
        vif.pwdata <= tr.pwdata;
        //access mode
        vif.penable <= 1;
        //wait for ready (handshake)
        wait(vif.pready == 1);

        //check for PSLVERR
        tr.pslverr = vif.pslverr;
        if(vif.pslverr == 1) begin
            `uvm_error()
        end
        //capture read data
        if(!tr.pwrite) begin
            tr.prdata = vif.prdata;
        end
        //deasser signals
        @(posedge vif.pclk);
        vif.penable <= 1'b0;
        vif.psel <= 1'b0;
    endtask
endclass

//APB monitor
class apb_ram_monitor extends uvm_monitor;
    
    `uvm_component_utils(apb_ram_monitor)

    virtual apb_ram_if vif;  // Virtual interface
    uvm_analysis_port #(apb_ram_transaction) send;  // Analysis port for scoreboard

    // Constructor
    function new(string name = "apb_ram_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        send = new("send", this);

        if (!uvm_config_db#(virtual apb_ram_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual interface not found")
    endfunction

    // Run phase
    task run_phase(uvm_phase phase);
        forever begin
            apb_ram_transaction tr;
            tr = apb_ram_transaction::type_id::create("tr");

            @(posedge vif.pclk);

            if (vif.psel && vif.penable) begin
                tr.addr   = vif.paddr;
                tr.pwrite = vif.pwrite;

                if (tr.pwrite) begin
                    tr.wdata = vif.pwdata;
                end else begin
                    tr.rdata = vif.prdata;
                end

                tr.pslverror = vif.pslverror;

                `uvm_info("MON", $sformatf(
                    "Captured Transaction - Mode:%0s, Addr:%0h, WData:%0h, RData:%0h, PSLVERR:%0d",
                    (tr.pwrite) ? "WRITE" : "READ",
                    tr.addr, tr.wdata, tr.rdata, tr.pslverror
                ), UVM_MEDIUM)

                send.write(tr);  // Send transaction to scoreboard
            end
        end
    endtask
endclass

//APB sequence
class apb_ram_sequence extends uvm_sequence#(packet_transaction);
    `uvm_object_utils(apb_ram_sequence)

    packet_transaction tr;

    function new(string name = "apb_ram_sequence");
        super.new(name);
    endfunction

    virtual task body();
        repeat(20) begin
            tr = packet_transaction::type_id::create("tr");

            start_item(tr);
            assert(tr.randomize() with {
                tr.pwrite dist { 1'b0:= 50, 1'b1:= 50};
            });

            //introduce PSLVERR injection 
            if($urandom_range(0,100) < 20) begin
                assert(tr.randomize() with {tr.paddr dist {
                    [0:32'h0000_FFFF] := 80, [32'hFFFF_F000 : 32'hFFFF_FFFF] := 20
                };
            });
            end

            if(tr.pwrite) begin
                tr.pwdata = $urandom_range(0, 255);
            end
            finish_item(tr);
        end
    endtask
endclass

//SPI Driver

class spi_master_driver extends uvm_driver#(spi_transaction);
    `uvm_component_utils(spi_master_driver)

    virtual spi_if vif;
    spi_transaction tr;

    // Constructor
    function new(string name = "spi_master_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    // Build Phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual spi_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Unable to access the interface");
    endfunction

    // Run Phase
    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(tr);

            vif.cs <= 1'b0;  // Select slave
            `uvm_info("DRV", "Starting SPI transaction", UVM_NONE);

            // Write Operation
            if (tr.op == writed) begin
                vif.mosi <= 1'b0;  // R/W = 0 for Write
                @(posedge vif.sclk);

                // Send Address
                for (int i = 7; i >= 0; i--) begin
                    vif.mosi <= tr.addr[i];
                    @(posedge vif.sclk);
                end

                // Send Data
                for (int i = 7; i >= 0; i--) begin
                    vif.mosi <= tr.data_out[i];
                    @(posedge vif.sclk);
                end
            end

            // Read Operation
            else if (tr.op == readd) begin
                vif.mosi <= 1'b1;  // R/W = 1 for Read
                @(posedge vif.sclk);

                // Send Address
                for (int i = 7; i >= 0; i--) begin
                    vif.mosi <= tr.addr[i];
                    @(posedge vif.sclk);
                end

                // Receive Data
                for (int i = 7; i >= 0; i--) begin
                    @(posedge vif.sclk);
                    tr.data_in[i] = vif.miso;
                end
            end

            vif.cs <= 1'b1;  // Deselect slave
            `uvm_info("DRV", $sformatf("SPI Transaction Complete: Sent = %h, Received = %h", tr.data_out, tr.data_in), UVM_NONE);

            seq_item_port.item_done();
        end
    endtask
endclass