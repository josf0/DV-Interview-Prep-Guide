//typedef enum bit [1:0] {readd= 0, drived = 1, rstdut = 2} oper_mode;

class packet_transaction extends uvm_sequence_item;

    rand logic rst;
    rand logic valid;
    rand logic ready;
    rand logic sop;
    rand logic eop;
    rand logic [31:0] data[];
    rand logic [3:0] keep[];
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
        `uvm_field_array_int(data, UVM_ALL_ON)
        `uvm_field_array_int(keep, UVM_ALL_ON)
        `uvm_field_int(length, UVM_ALL_ON)
        `uvm_field_int(dest, UVM_ALL_ON)
        `uvm_field_int(src, UVM_ALL_ON)
        //`uvm_field_enum(oper_mode, op, UVM_DEFAULT)
    `uvm_object_utils_end

    constraint valid_dest {
        dest inside {2'b00, 2'b01, 2'b10};
    }

    constraint valid_length {
        length inside {[12'h000:12'hFFF]}; // Include 4096 words case
    }

    constraint valid_src {
        src inside {2'b00, 2'b01};
    }

    constraint valid_data_size {
        data.size() == (length == 12'h000 ? 4096 : length);
    }

    constraint valid_keep_size {
        keep.size() == (length == 12'h000 ? 4097 : length + 1);
    }

    constraint valid_keep {
        foreach (keep[i]) {
            (i < (keep.size()-1)) -> keep[i] == 4'b1111;
            (i == (keep.size()-1)) -> keep[i] == 4'b0001;
        }
    }
    
    
    function new(string path = "packet_transaction");
        super.new(path);
    endfunction

    function void compute_crc();
        bit [31:0] control_word = {8'h00, 8'h00, src, dest, length};
        // CRC should be kept to 00 while computing the CRC itself
        crc = calculate_crc(control_word);
    endfunction

    //functional coverage group

    //  Covergroup: cg_transaction
    //
    covergroup cg_transaction;
        option.per_instance = 1;

        length_cp: coverpoint length {
            bins small = {[1:4]};
            bins medium = {[5:100]};
            bins large = {[101:4095]};
            bins max = {4096};
        }

        src_cp: coverpoint src {
            bins src_0 = {2'b00};
            bins src_1 = {2'b01};
        }

        dest_cp: coverpoint dest {
            bins dest_0 = {2'b00};
            bins dest_1 = {2'b01};
            bins dest_2 = {2'b10};
        }

        sop_cp: coverpoint sop;
        eop_cp: coverpoint eop;

        valid_ready_cp: cross valid, ready{
            ignore_bins not_valid = binsof(valid) intersect {0};
            ignore_bins not_ready = binsof(ready) intersect {0};
        }

        src_dest_cp: cross src_cp, dest_cp;
        sop_eop_cp: cross sop_cp, eop_cp;

        crc_cp: coverpoint crc {
            bins low_range = {[8'h00:8'h3F]};  // Lower range
            bins mid_range = {[8'h40:8'hBF]};  // Middle range
            bins high_range = {[8'hC0:8'hFF]}; // Higher range
        }
    endgroup

    function new(string path = "packet_transaction");
        super.new(path);
        cg_transaction = new();
    endfunction

    function void sample_coverage();
        cg_transaction.sample();
    endfunction
endclass