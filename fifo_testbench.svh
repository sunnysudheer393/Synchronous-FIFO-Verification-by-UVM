`timescale 1ns/100ps
//include all the components here for UVM including interface
import uvm_pkg::*;
`include "uvm_macros.svh"

`include "fifo_seq_item.sv"
`include "fifo_sequencer.sv"
`include "fifo_sequence.sv"
`include "fifo_driver.sv"
`include "fifo_interface.sv"
`include "fifo_monitor.sv"
`include "fifo_agent.sv"
`include "fifo_scoreboard.sv"
`include "fifo_env.sv"
`include "fifo_test.sv"
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
                    .rst_n(intf.rst_n), .wr_en(intf.wr_en), .rd_en(intf.rd_en),
                    .full(intf.full), .empty(intf.empty), .data_out(intf.data_out));

//set the interface in configuration database
initial begin
    uvm_config_db #(virtual fifo_interface)::set(null,"*","vif",vif);
end

initial begin
    run_test("fifo_test");
end

initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
end
//start the run_test

/*
EDA Playground Link:
https://edaplayground.com/x/FCVK
*/
//dump the values into vcd to view the waveform


endmodule

initial begin
a = 0;
b = 1;
c = 0;
d = 1;
end

always @(event) begin
a <= b;
b <= a;
c = d;
d = c;
end
