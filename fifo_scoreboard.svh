`include "uvm_macros.svh"  // Accesses macros like `uvm_info and `uvm_component_utils
import uvm_pkg::*;
//import async_fifo_pkg::*;

import "DPI-C" function int c_fifo_scoreboard(int wr_en, int rd_en, int data_in, int data_out, int full, int empty);

class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)
    //it'll have analysis imp port to get from monitor
    uvm_analysis_imp #(fifo_seq_item,fifo_scoreboard) scb_port;

    fifo_seq_item que[$];
    //fifo_seq_item trans;
  	fifo_seq_item tr;  
  virtual fifo_interface vif;
    int passed, failed;
  	int status = -1;
    /*
    scoreboard has reference model for the DUT to verify the inputs
    so it need signals to store the data and check it with dut output
    it'll have memory fifo and data input signal or output to match with dut

    */
  bit [7:0] mem[$];
  bit [7:0] tx_data;
   // bit read_delay_clk;

    function new(string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb_port = new("scb_port",this);
        if(!uvm_config_db #(virtual fifo_interface)::get(this,"","vif",vif)) begin
          `uvm_error("build_phase","No virtual interface specified for this Scoreboard instance");
        end
    endfunction

    //write function implementation(push value into the queue)
  function write(fifo_seq_item tr);
    que.push_back(tr);
      //   int status;
      //   status = c_fifo_scoreboard(tr.wr_en, tr.rd_en, tr.data_in, tr.data_out, tr.full, tr.empty);

      // 	if(status !=0)failed++;
      //   else if(tr.rd_en) passed++;
      // $display("passed: %0d, failed: %0d", passed, failed);

    endfunction

    virtual task run_phase(uvm_phase phase);
    forever begin
        wait(que.size()>0);
        tr = que.pop_front();
		
      if(tr.wr_en || tr.rd_en) begin
        	$display("Data_out from Design is: %0d", tr.data_out);
        	status = c_fifo_scoreboard(tr.wr_en, tr.rd_en, tr.data_in, tr.data_out, tr.full, tr.empty);
      end
          
        //int status;
     

      if(status == 0)failed++;
      else if(status == 1) passed++;
      
        $display("passed: %0d, failed: %0d", passed, failed);
    end  
      
    endtask



//     virtual task run_phase(uvm_phase phase);
//     forever begin
//         wait(que.size()>0);
//         trans = que.pop_front();

//         //Write occured
//       if(trans.wr_en==1 && !trans.full) begin
//           mem.push_back(trans.data_in);
//         end

//         //Read occured
//         if(trans.rd_en == 1) begin
//           if(mem.size()>0) begin
//             tx_data <= mem.pop_front();
//             if(tx_data!== trans.data_out) begin
//               `uvm_info("Scoreboard",$sformatf("--Output Mis-matched---"), UVM_MEDIUM)
//               `uvm_info("Scoreboard , ",$sformatf("[%0t]   Exp data=%0d, Rec data=%0d",$time, tx_data,trans.data_out),UVM_MEDIUM)
//               failed++;
//             end else begin
//               `uvm_info("Scoreboard",$sformatf("---Output Matched---"),UVM_MEDIUM)
//               `uvm_info("Scoreboard", $sformatf("[%0t]   Exp Data=%0d, Rec data=%0d", $time, tx_data,trans.data_out), UVM_MEDIUM)
//               passed++;
//             end
//           end
//         end
//       $display("passed: %0d, failed: %0d", passed, failed);
//     end  
      
//    endtask
  
  
    // virtual task run_phase(uvm_phase phase);
    //   `uvm_info("Scoreboard", $sformatf("Scoreboard Run Phase Started"), UVM_LOW)
    //   // Monitor incoming transactions
    //   forever begin
    //     //$display("passed: %0d, failed: %0d", passed, failed);
    //   end
    // endtask

endclass
