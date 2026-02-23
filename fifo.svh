module fifo_design #( parameter FIFO_DEPTH = 8, parameter DATA_WIDTH = 8) 
    (input clk, 
     input rst,
     input wr_en, 
     input rd_en, 
     input [DATA_WIDTH-1:0] data_in, 

     output reg [DATA_WIDTH-1:0] data_out, 
	 output empty,
	 output full
     ); 

    localparam FIFO_DEPTH_LOG = $clog2(FIFO_DEPTH);
	
    // Declare a by-dimensional array to store the data
	logic [DATA_WIDTH-1:0] fifo [0:FIFO_DEPTH-1];
	
	// Wr/Rd pointer have 1 extra bits at MSB to us total fifo storage capacity
    logic [FIFO_DEPTH_LOG:0] write_pointer = '0;
    logic [FIFO_DEPTH_LOG:0] read_pointer = '0;

    always @(posedge clk) begin
      if(rst)//rst =0 system reset happens
		    write_pointer <= 0;
      else if ( wr_en && !full) begin
        	fifo[write_pointer[FIFO_DEPTH_LOG-1:0]] <= data_in;
	        write_pointer <= write_pointer + 1'b1;
      end
	end
	
	always @(posedge clk) begin
	    if(rst)
		    read_pointer <= 0;
      else if (rd_en && !empty) begin
        	data_out <= fifo[read_pointer[FIFO_DEPTH_LOG-1:0]];
	        read_pointer <= read_pointer + 1'b1;
      end
	end
	
	// Declare the empty/full logic
    assign empty = (read_pointer == write_pointer);
    assign full  = (read_pointer[FIFO_DEPTH_LOG] != write_pointer[FIFO_DEPTH_LOG]) &&
               (read_pointer[FIFO_DEPTH_LOG-1:0] == write_pointer[FIFO_DEPTH_LOG-1:0]);
	

endmodule
