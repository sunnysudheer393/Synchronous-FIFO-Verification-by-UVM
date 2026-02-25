// Code your testbench here
// or browse Examples
//`timescale 1ns/100ps
//include all the components here for UVM including interface
//import "DPI-C" function int c_fifo_scoreboard(int wr_en, int rd_en, int data_in, int data_out, int full, int empty);

import uvm_pkg::*;
`include "uvm_macros.svh"


`include "fifo_seq_item.svh"
`include "fifo_sequencer.svh"
`include "fifo_sequence.svh"
`include "fifo_monitor.svh"
`include "fifo_driver.svh"
`include "fifo_interface.svh"
`include "fifo_agent.svh"
`include "fifo_scoreboard.svh"
`include "fifo_environment.svh"
`include "fifo_test.svh"
`include "fifo_read_test.svh"
`include "fifo_write_read_test.svh"
`include "fifo_write_test.svh"
`include "fifo_write_then_read.svh"

//`include "fifo_test.svh"
//include other test files or sequences if there for fifo

module fifo_testbench();
//we'll generate clock and reset here
bit clk;
bit rst_n;
initial begin : clock_generation
    clk <= 0;
    forever begin
        clk <= ~clk;
        #5;
    end
end

initial begin : reset_logic
    rst_n <= 0;
    #2; //repeat(2) @(posedge clk);
    rst_n <= 1;//resets for 2 clock cycles(reset is active low)
end

//Instantiate the interface and pass clk, rst from tb
fifo_interface intf(clk,rst_n);

//Instantiate the DUT and connect with ports of Interface

synchronous_fifo dut(.data_in(intf.data_in), .clk(intf.clk),
                     .rst(intf.rst_n), .wr_en(intf.wr_en), .rd_en(intf.rd_en),
                    .full(intf.full), .empty(intf.empty), .data_out(intf.data_out));

//set the interface in configuration database
initial begin
  uvm_config_db#(virtual fifo_interface)::set(null,"*","vif",intf);
end

initial begin
    run_test("fifo_test");
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
end
//start the run_test

endmodule
