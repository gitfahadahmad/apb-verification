class monitor extends uvm_monitor;
    
    `uvm_component_utils(monitor)

    uvm_analysis_port#(apb_transaction) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual apb_if vif;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
        `uvm_fatal("Monitor", "Virtual Interface not found")

        ap = new("ap", this);

    endfunction

    virtual task run_phase(uvm_phase phase);
        //super.run_phase(phase);

        apb_transaction tr;

        forever begin
            @(vif.mon_cb);

            if(vif.mon_cb.PSEL && vif.mon_cb.PENABLE && vif.mon_cb.PREADY) begin

                
                tr = apb_transaction::type_id::create("tr");

                //sampling the bus signals
                tr.addr = vif.mon_cb.PADDR;
                tr.write = vif.mon_cb.PWRITE;

                tr.wdata = vif.mon_cb.PWDATA;
                tr.rdata = vif.mon_cb.PRDATA;
                tr.strb = vif.mon_cb.PSTRB;
                tr.slverr = vif.mon_cb.PSLVERR;

                `uvm_info("Monitor", $sformatf("Sampled transaction: ADDR = %0h, Write = %0b, WDATA = %0h, RDATA = %0h, STRB = %0b, PSLVERR = %0h \n", tr.addr, tr.write, tr.wdata, tr.rdata, tr.strb, tr.slverr), UVM_LOW)

                //sending the tr to the scoreboard
                ap.write(tr);

            end
        end

    endtask

endclass