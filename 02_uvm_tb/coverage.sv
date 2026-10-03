class apb_coverage extends uvm_subscriber #(apb_transaction);

    `uvm_component_utils(apb_coverage)

    apb_transaction tr;

    covergroup apb_cov;
        option.per_instance = 1;

        cp_address: coverpoint tr.addr {
            bins ctrl_reg = {12'h000};
            bins status_reg = {12'h004};
            bins int_en_reg = {12'h008};
            bins int_status_reg = {12'h00C};
            bins scratch_reg = {12'h010};
            bins timer_load_reg = {12'h014};
            bins timer_ctrl_reg = {12'h018};
            bins timer_val_reg = {12'h01C};
            bins fifo_data_reg = {12'h020};
            bins fifo_status_reg = {12'h024};

            bins ram_low = {[12'h100:12'h13C]};
            bins ram_mid1 = {[12'h140:12'h17C]};
            bins ram_mid2 = {[12'h180:12'h1BC]};
            bins ram_high = {[12'h1C0:12'h1FC]};

            bins invalid = default;
        }

        cp_wr: coverpoint tr.write {
            bins write_op = {1'b1};
            bins read_op = {1'b0};
        }

        cp_strobe: coverpoint tr.strb {
            bins byte0 = {4'b0001};
            bins byte1 = {4'b0010};
            bins byte2 = {4'b0100};
            bins byte3 = {4'b1000};
            bins halfword_low = {4'b0011};
            bins halfword_high = {4'b1100};
            bins word = {4'b1111};
            bins no_strobe = {4'b0000};
            bins other = default;
        }

        cp_error: coverpoint tr.slverr {
            bins no_error = {1'b0};
            bins error = {1'b1};
        }

        cross_addr_x_op: cross cp_address, cp_wr;

        cross_op_x_strobe: cross cp_wr, cp_strobe {
            ignore_bins read_strobes = binsof(cp_wr) intersect {1'b0};
        }

    endgroup

    function new(string name = "apb_coverage", uvm_component parent = null);
        super.new(name, parent);
        apb_cov = new();
        apb_cov.set_inst_name(name);
    endfunction

    virtual function void write(apb_transaction t);
        tr = t;
        apb_cov.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("COVERAGE",
        $sformatf("APB Functional Coverage = %0.2f%%",
        apb_cov.get_inst_coverage()), UVM_NONE)
        //============================================

        `uvm_info("COVERAGE",
        $sformatf("Address Coverage = %0.2f%%",
        apb_cov.cp_address.get_inst_coverage()), UVM_NONE)

        `uvm_info("COVERAGE",
        $sformatf("Read/Write Coverage = %0.2f%%",
        apb_cov.cp_wr.get_inst_coverage()), UVM_NONE)

        `uvm_info("COVERAGE",
        $sformatf("PSTRB Coverage = %0.2f%%",
        apb_cov.cp_strobe.get_inst_coverage()), UVM_NONE)

        `uvm_info("COVERAGE",
        $sformatf("SLVERR Coverage = %0.2f%%",
        apb_cov.cp_error.get_inst_coverage()), UVM_NONE)

        `uvm_info("COVERAGE",
        $sformatf("Address x Read/Write = %0.2f%%",
        apb_cov.cross_addr_x_op.get_inst_coverage()), UVM_NONE)

        `uvm_info("COVERAGE",
        $sformatf("Read/Write x PSTRB = %0.2f%%",
        apb_cov.cross_op_x_strobe.get_inst_coverage()), UVM_NONE)

    endfunction

endclass