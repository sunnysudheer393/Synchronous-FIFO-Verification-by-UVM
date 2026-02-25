//`define MON_IF vif.Monitor.monitor_cb;
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
      	if(!uvm_config_db #(virtual fifo_interface)::get(this,"*","vif",vif)) begin
            `uvm_error("build_phase","No virtual interface specified for this monitor instance");
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            //wait(`MON_IF.wr_en == 1 || `MON_IF.rd_en == 1)
          //trans = fifo_seq_item::type_id::create("trans");
          @(posedge vif.clk);
          	trans = fifo_seq_item::type_id::create("trans");
          
            trans.wr_en = vif.monitor_cb.wr_en;
            trans.rd_en = vif.monitor_cb.rd_en;
            trans.data_in = vif.monitor_cb.data_in;

            trans.empty = vif.monitor_cb.empty;
            trans.full = vif.monitor_cb.full;
            trans.data_out = vif.monitor_cb.data_out;
          //$display("Data_out from DUT: %0d", trans.data_out);
          	
            mon_port.write(trans);//calls scoreboard write method
        end
    endtask

endclass
