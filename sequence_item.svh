`include "uvm_macros.svh"

class fifo_seq_item extends uvm_sequence_item #(parameter int Width = 8);
    `uvm_object_utils(fifo_seq_item)

    //contain data and control signals which need to be randomized and declared as rand/randc
    rand bit[Width-1:0]data_in;
    rand bit wr_en;
    rand bit rd_en;
    //this packet utilized in sequence class for randomization and started in run phase of the test class

    bit full;
    bit empty;
    bit [Width-1:0]data_out;

    virtual function automatic void new(string name = "fifo_seq_item");
        super.new(name);
    endfunction
endclass
