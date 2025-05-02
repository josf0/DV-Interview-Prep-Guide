interface M_if(input logic clk, input logic rst);

    // Master Interface Signals
    logic        m_valid;
    logic        m_ready;
    logic        m_sop;
    logic        m_eop;
    logic [31:0] m_data;
    logic [3:0]  m_keep;
    logic [11:0] m_length;
    logic [1:0]  m_dest;
    logic [1:0]  m_src;
    logic [7:0]  m_crc;

    // Clocking block for Driver
    clocking cb_drv @(posedge clk);
        output m_valid, m_sop, m_eop, m_data, m_keep, m_dest, m_src, m_crc;
        input  m_ready;
    endclocking

    // Clocking block for Monitor
    clocking cb_mon @(posedge clk);
        input m_valid, m_sop, m_eop, m_data, m_keep, m_dest, m_src, m_crc, m_ready;
    endclocking

    // Modports
    modport driver  (input clk, rst, output m_valid, m_sop, m_eop, m_data, m_keep, m_dest, m_src, m_crc, input m_ready);
    modport monitor (input clk, rst, input m_valid, m_sop, m_eop, m_data, m_keep, m_dest, m_src, m_crc, m_ready);

   // Assertion to check that SOP is asserted only when valid is high
    a_sop_valid: assert property (@(posedge clk) disable iff (rst) (m_sop |-> m_valid))
    else `uvm_error("ASSERT", "SOP asserted without valid high")

    // Assertion to check that the control word is fully transferred when SOP is asserted
    a_control_word_transfer: assert property (@(posedge clk) disable iff (rst) (m_sop |-> (m_keep == 4'b1111)))
    else `uvm_error("ASSERT", "Control word must have full keep")

    // Assertion to check that the first word after SOP is the control word
    a_control_word_format: assert property (@(posedge clk) disable iff (rst) 
        (m_sop |-> (m_data[31:24] == 8'h00)))
    else `uvm_error("ASSERT", "Invalid control word format")

    // Assertion to ensure that valid is high throughout the transfer
    a_valid_high_during_transfer: assert property (@(posedge clk) disable iff (rst) 
        (m_valid && !m_eop |=> m_valid))
    else `uvm_error("ASSERT", "Valid deasserted before EOP")

    // Assertion to check that EOP is asserted only at the last data word
    a_eop_last_word: assert property (@(posedge clk) disable iff (rst) 
        (m_eop |=> ##[0:$] (!m_valid && !m_ready))
    else `uvm_error("ASSERT", "EOP asserted but valid is still high afterward")

    // Assertion to check that destination is valid (not 2'b11)
    a_valid_dest: assert property (@(posedge clk) disable iff (rst) 
        (m_sop |-> m_dest != 2'b11))
    else `uvm_error("ASSERT", "Invalid destination address received")

    // Assertion to check that length field follows protocol
    a_length_valid: assert property (@(posedge clk) disable iff (rst) 
        (m_sop |-> (m_length <= 12'hFFF)))
    else `uvm_error("ASSERT", "Invalid packet length")

    // Assertion to check that CRC calculation is correct
    a_crc_check: assert property (@(posedge clk) disable iff (rst) 
        (m_sop |-> (m_crc == calculate_crc({8'h00, 8'h00, m_src, m_dest, m_length}))))
    else `uvm_error("ASSERT", "CRC mismatch detected")

endinterface
