interface fifo_interface #(parameter Width = 8)(input logic clk, rst_n);
    logic [Width-1:0] data_in;
    logic [Width-1:0] data_out;
    logic wr_en;
    logic rd_en;
    logic full;
    logic empty;
    logic [$clog2(Width)-1:0] fifo_cnt;

    //we need intf signal for both driver and monitor
    //for which signals of inputs to driver becomes output signals to monitor and viceversa
    clocking driver_cb @(posedge clk);
        //default input #1 output #1;
        output data_in;
        output wr_en,rd_en;
        input full,empty;
        input data_out;
    endclocking

    clocking monitor_cb @(posedge clk);
        //default input #1 output #1;
        input data_in;
        input wr_en,rd_en;
        output full,empty;
        output data_out;
    endclocking

    //modports are used to define inputs and outputs for the interface signals
    modport Driver(clocking driver_cb, input clk,rst);//modport for driver
    modport Monitor(clocking monitor_cb, input clk,rst);//modport for monitor

endinterface
