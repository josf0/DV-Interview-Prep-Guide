interface S_if(input logic clk, input logic rst_n);

    // Slave Interface Signals
    logic        s_valid;
    logic        s_ready;
    logic        s_sop;
    logic        s_eop;
    logic [31:0] s_data;
    logic [3:0]  s_keep;
    logic [1:0]  s_dest;
    logic [1:0]  s_src;
    logic [7:0]  s_crc;

    // Clocking block for Driver
    clocking cb_drv @(posedge clk);
        output s_ready;
        input  s_valid, s_sop, s_eop, s_data, s_keep, s_dest, s_src, s_crc;
    endclocking

    // Clocking block for Monitor
    clocking cb_mon @(posedge clk);
        input s_valid, s_sop, s_eop, s_data, s_keep, s_dest, s_src, s_crc, s_ready;
    endclocking

    // Modports
    modport driver  (input clk, rst_n, input s_valid, s_sop, s_eop, s_data, s_keep, s_dest, s_src, s_crc, output s_ready);
    modport monitor (input clk, rst_n, input s_valid, s_sop, s_eop, s_data, s_keep, s_dest, s_src, s_crc, s_ready);

endinterface
