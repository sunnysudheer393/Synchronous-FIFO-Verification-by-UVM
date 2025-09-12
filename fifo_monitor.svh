`define MON_IF vif.Monitor.monitor_cb;
class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)//it receives packets from interface

    virtual fifo_interface vif;
    fifo_seq_item trans;

    //need analysis port to connect to other componenets
    uvm_analysis_port #(fifo_seq_item) mon_port;

    function new(string name, uvm_component parent);
        super.new(name,parent);
        mon_port = new("mon_port",this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual fifo_interface::get(this,"*","vif",vif))) begin
            `uvm_error("build_phase","No virtual interface specified for this monitor instance");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        trans = fifo_seq_item::type_id::create("trans");
        forever begin
            @(posedge vif.Monitor.clk);
            wait(`MON_IF.wr_en == 1 || `MON_IF.rd_en == 1)
                trans.wr_en = `MON_IF.wr_en;
                trans.rd_en = `MON_IF.rd_en;
                trans.data_in = `MON_IF.data_in;

                trans.empty = `MON_IF.empty;
                trans.full = `MON_IF.full;
                trans.data_out = `MON_IF.data_out;
            mon_port.write(trans);//calls scoreboard write method
        end
    endtask

endclass
