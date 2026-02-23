clear -all

analyze -sv12 fifo.sv

analyze -sv12 fifo_fv_tb.sv \ fifo_bind.sv

check_cov -init -type all -model {branch toggle statement} -toggle_ports_only

elaborate -top fifo_design

clock clk

reset -expression {rst == 1'b1}

prove -all

check_cov -measure -type {coi stimuli proof bound} -time_limit 60s -bg