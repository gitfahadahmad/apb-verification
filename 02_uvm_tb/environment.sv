class environment extends uvm_env;

    `uvm_component_utils(environment)
    
    agent agt;
    scoreboard scb;
    apb_coverage cov;


    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agt = agent::type_id::create("agt", this);
        scb = scoreboard::type_id::create("scb", this);
        cov = apb_coverage::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
    
        super.connect_phase(phase);


        agt.mon.ap.connect(scb.sb_ap);
        agt.mon.ap.connect(cov.analysis_export);
    endfunction

endclass