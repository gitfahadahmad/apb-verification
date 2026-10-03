class driver extends uvm_driver#(apb_transaction);

        `uvm_component_utils(driver)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual apb_if vif;

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
            `uvm_error("Driver Error", "Interface not found")

        endfunction

        virtual task run_phase(uvm_phase phase);

            apb_transaction tr;

            wait(vif.PRESETn == 1); //active low reset
            @(vif.drv_cb);

            forever begin
                seq_item_port.get_next_item(tr); // geting the next tr from the sequencer
                `uvm_info("  Driver", $sformatf("Driving transaction: ADDR = %0h, Write = %0b, WDATA = %0h, RDATA = %0h, STRB = %0b, PSLVERR = %0h", tr.addr, tr.write, tr.wdata, tr.rdata, tr.strb, tr.slverr), UVM_LOW)

                @(vif.drv_cb); //setup stage 1st clk
                vif.drv_cb.PSEL <= 1'b1;
                vif.drv_cb.PENABLE <= 1'b0;

                vif.drv_cb.PADDR <= tr.addr;
                vif.drv_cb.PWRITE <= tr.write;
                vif.drv_cb.PWDATA <= tr.wdata;
                vif.drv_cb.PSTRB <= tr.strb;

                @(vif.drv_cb); //2nd stage access 2nd clk
                vif.drv_cb.PENABLE <= 1'b1;

                @(vif.drv_cb); // 3rd stage done stage, wait for the dut resposnse
                
                wait(vif.drv_cb.PREADY);
                tr.rdata = vif.drv_cb.PRDATA;

                //returning back to idle state
                vif.drv_cb.PENABLE <= 1'b0;
                vif.drv_cb.PSEL <= 1'b0;

                @(vif.drv_cb);

                seq_item_port.item_done();
            end

        endtask



endclass