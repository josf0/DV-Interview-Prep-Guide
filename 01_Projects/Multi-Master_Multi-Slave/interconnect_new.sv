class interconnect;
    virtual M_if m0_if, m1_if;
    virtual S_if s0_if, s1_if, s2_if;

    function new(virtual M_if m0_if, virtual M_if m1_if, virtual S_if s0_if, virtual S_if s1_if, virtual S_if, s2_if);
        this.m0_if = m0_if;
        this.m1_if = m1_if;
        this.s0_if = s0_if;
        this.s1_if = s1_if;
        this.s2_if = s2_if;
    endfunction

    task run();
        forever begin
            wait(m0_if.m_valid || m1_if.m_valid);
            //route transaction
            if(m0_if.m_valid) begin
                forward_transaction(m0_if);
            end
            else if(m1_if.m_valid) begin
                forward_transaction(m1_if);
            end
        end
    endtask

    task forward_transaction(virtual M_if m_if);
        virtual S_if s_if;

        case(m_if.m_dest)
            2'b00: s_if = s0_if;
            2'b01: s_if = s1_if;
            2'b10: s_if = s2_if;
            default: begin
                `uvm_error();
                return;
            end
        endcase

        //transfer the data
        s_if.s_valid <= 1;
        s_if.s_sop <= m_if.m_sop;
        s_if.s_eop <= m_if.m_eop;
        s_if.s_data <= m_if.m_data;
        s_if.s_keep <= m_if.m_keep;
        s_if.s_dest <= m_if.m_dest;
        s_if.s_src <= m_if.m_src;
        s_if.s_crc <= m_if.m_crc;
        //wait for slave to be ready
        wait(s_if.s_ready);
        s_if.s_valid<= 0;
    endtask
endclass