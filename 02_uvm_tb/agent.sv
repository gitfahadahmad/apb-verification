class agent extends uvm_agent;

    `uvm_component_utils(agent)

    driver drv;
    monitor mon;

    uvm_sequencer#(apb_transaction) sqr; //sequencer used from uvm base class without extending;
    //functional coverage missing


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        mon = monitor::type_id::create("mon", this);

        if(get_is_active() == UVM_ACTIVE) begin
                drv = driver::type_id::create("drv", this);
                sqr = uvm_sequencer#(apb_transaction)::type_id::create("sqr", this);

        end

    endfunction

    virtual function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        if(get_is_active() == UVM_ACTIVE) begin
        drv.seq_item_port.connect(sqr.seq_item_export); end

    endfunction

endclass