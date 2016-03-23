vsim -L altera_mf_ver -L lpm_ver multicycle_tb
mem load -i $1 -format mti /multicycle_tb/DUT/DataMem/b2v_inst/altsyncram_component/mem_data