class test extends uvm_test;

    `uvm_component_utils(test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    environment env;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = environment::type_id::create("env", this);
        
    endfunction

// // simple sequence
//     virtual task run_phase(uvm_phase phase);
        
//         apb_sequence seq;

//         //Objection
//         phase.raise_objection(this);
//         seq = apb_sequence::type_id::create("seq", this);
//         `uvm_info("Test", "Starting the Smoke Sequence....", UVM_LOW)
//         seq.start(env.agt.sqr);
//         `uvm_info("Test", "Smoke Sequence Completed", UVM_LOW)
//         phase.drop_objection(this);


//     endtask

//smoke_sequence

// virtual task run_phase(uvm_phase phase);

//         apb_smoke_sequence smoke_seq;

//         phase.raise_objection(this);
        
//         `uvm_info("TEST", "Starting the Smoke Sequence...", UVM_LOW)
        
//         // Wait for the reset to complete 
//        // #25; 

//         // Create and start the sequence
//         smoke_seq = apb_smoke_sequence::type_id::create("smoke_seq");
//         smoke_seq.start(env.agt.sqr); 
        
//         `uvm_info("TEST", "Smoke Sequence Completed", UVM_LOW)
        
//         phase.drop_objection(this);
//     endtask


    // //Register Sequence
    // virtual task run_phase(uvm_phase phase);
    //     apb_reg_sequence reg_seq;

    //     phase.raise_objection(this);
        
    //     `uvm_info("TEST", "Starting the Register Bank Sequence...", UVM_LOW)
        
    //     reg_seq = apb_reg_sequence::type_id::create("reg_seq");
    //     reg_seq.start(env.agt.sqr); 
        
    //     `uvm_info("TEST", "Register Sequence Completed", UVM_LOW)
        
    //     phase.drop_objection(this);
    // endtask

    // //RAM Sequence
    // virtual task run_phase(uvm_phase phase);
    //     apb_ram_sequence ram_seq;

    //     phase.raise_objection(this);
        
    //     `uvm_info("TEST", "Starting the RAM Sequence...", UVM_LOW)
        
    //     ram_seq = apb_ram_sequence::type_id::create("ram_seq");
    //     ram_seq.start(env.agt.sqr); 
        
    //     `uvm_info("TEST", "RAM Sequence Completed", UVM_LOW)
        
    //     phase.drop_objection(this);
    // endtask

    // FIFO Sequence Task
    // virtual task run_phase(uvm_phase phase);
    //     apb_fifo_sequence fifo_seq;

    //     phase.raise_objection(this);
    //     `uvm_info("TEST", "Starting the FIFO Sequence...", UVM_LOW)
    //     fifo_seq = apb_fifo_sequence::type_id::create("fifo_seq");
    //     fifo_seq.start(env.agt.sqr); 
    //     `uvm_info("TEST", "FIFO Sequence Completed", UVM_LOW)
    //     phase.drop_objection(this);

    //  endtask

// //      // Timer & Interrupt Sequence Task
//     virtual task run_phase(uvm_phase phase);
//         apb_timer_interrupt_sequence timer_seq;

//         phase.raise_objection(this);
        
//         `uvm_info("TEST", "Starting the Timer & Interrupt Sequence...", UVM_LOW)
        
//         timer_seq = apb_timer_interrupt_sequence::type_id::create("timer_seq");
//         timer_seq.start(env.agt.sqr); 
        
//         `uvm_info("TEST", "Timer & Interrupt Sequence Completed", UVM_LOW)
        
//         phase.drop_objection(this);
//     endtask

// // Error Sequence Task
    // virtual task run_phase(uvm_phase phase);
    //     apb_error_sequence err_seq;

    //     phase.raise_objection(this);
        
    //     `uvm_info("TEST", "Starting the Error Handling Sequence...", UVM_LOW)
        
    //     err_seq = apb_error_sequence::type_id::create("err_seq");
    //     err_seq.start(env.agt.sqr); 
        
    //     `uvm_info("TEST", "Error Handling Sequence Completed", UVM_LOW)
        
    //     phase.drop_objection(this);
    // endtask

    // Random Stress Sequence Task
    virtual task run_phase(uvm_phase phase);
        apb_random_sequence rand_seq;

        phase.raise_objection(this);
        
        `uvm_info("TEST", "Starting the Random Stress Sequence...", UVM_LOW)
        
        rand_seq = apb_random_sequence::type_id::create("rand_seq");
        
        // Randomize the sequence itself to determine num_trans before starting
        if(!rand_seq.randomize()) begin
             `uvm_fatal("TEST", "Failed to randomize the random sequence object");
        end
        
        rand_seq.start(env.agt.sqr); 
        
        `uvm_info("TEST", "Random Stress Sequence Completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask

endclass

