`include "uvm_macros.svh"

class fifo_seq_item extends uvm_sequence_item();
    `uvm_object_utils(fifo_seq_item)

    //contain data and control signals which need to be randomized and declared as rand/randc
  rand bit[7:0]data_in='0;
    rand bit wr_en=0;
    rand bit rd_en=0;
    //this packet utilized in sequence class for randomization and started in run phase of the test class

    bit full;
    bit empty;
    bit [7:0]data_out;
  
    function new(string name="fifo_seq_item");
        super.new(name);
    endfunction
endclass
