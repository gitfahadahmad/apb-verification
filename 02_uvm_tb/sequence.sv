class apb_sequence extends uvm_sequence#(apb_transaction);
    `uvm_object_utils(apb_sequence)

    function new(string name = "apb_sequence");
        super.new(name);

    endfunction


    virtual task body();

        apb_transaction tr;

        repeat(5) begin
            
            tr = apb_transaction::type_id::create("tr");
            start_item(tr);
            `uvm_info("Sequence", "Starting the Transaction....", UVM_LOW)

            if(!tr.randomize()) 
                `uvm_fatal("ID", "Randomization Failed");

            `uvm_info("Sequence", "Sequence Completed....!", UVM_LOW)

            finish_item(tr); 
        end

    endtask

endclass

class apb_smoke_sequence extends uvm_sequence#(apb_transaction);
    `uvm_object_utils(apb_smoke_sequence)

    function new(string name = "apb_smoke_sequence");
        super.new(name);

    endfunction


    virtual task body();
        
        `uvm_info("Smoke Sequence", "Starting the Smoke Sequence...", UVM_LOW)
        
        //writing at the 0x010 in the scratch and reading back
        read_write(1, 12'h010, 32'hFAAA_FAAA, 4'b1111);
        read_write(0, 12'h010, 32'h0000_0000, 4'b1111);

        //writing and reading at the RAM 
        read_write(1, 12'h100, 32'hFAAA_FAAA, 4'b1111);
        read_write(0, 12'h100, 32'hFAAA_FAAA, 4'b1111);



    endtask

    task read_write(bit write_f, bit [11:0] addr_f, bit [31:0] wdata_f, bit[3:0] strb_f);

     apb_transaction tr;
                    
            tr = apb_transaction::type_id::create("tr");
            
            start_item(tr);
            `uvm_info("Sequence", "Starting the Transaction....", UVM_LOW)
            tr.write = write_f;
            tr.addr = addr_f;
            tr.wdata = wdata_f;
            tr.strb = strb_f;
            `uvm_info("Sequence", "Sequence Completed....!", UVM_LOW)
            finish_item(tr); 
    endtask

endclass

class apb_reg_sequence extends uvm_sequence#(apb_transaction);
    `uvm_object_utils(apb_reg_sequence)

    function new(string name = "apb_reg_sequence");
        super.new(name);
    endfunction

    virtual task body();
        apb_transaction tr;
        int num_trans = 50; 

        `uvm_info("REG_SEQ", "Starting Register Bank & PSTRB Sequence...", UVM_LOW)

        for (int i = 0; i < num_trans; i++) begin
            tr = apb_transaction::type_id::create("tr");
            
            start_item(tr);
            
            // Randomize with inline constraints for register testing
            if(!tr.randomize() with {
                // Target ONLY register addresses (0x000 to 0x024)
                addr >= 12'h000;
                addr <= 12'h024; 
                // Ensuring addresses are word-aligned (bottom 2 bits are 0)
                addr[1:0] == 2'b00;
            }) `uvm_fatal("REG_SEQ", "Randomization Failed");

            finish_item(tr);
        end

        `uvm_info("REG_SEQ", "Register Bank Sequence Completed!", UVM_LOW)
    endtask
endclass


class apb_ram_sequence extends uvm_sequence#(apb_transaction);
    `uvm_object_utils(apb_ram_sequence)

    function new(string name = "apb_ram_sequence");
        super.new(name);
    endfunction

    virtual task body();
        apb_transaction tr;
        int num_writes = 100;
        int num_reads  = 100;

        `uvm_info("RAM_SEQ", "Starting Scratch RAM Sequence...", UVM_LOW)

        // Random Writes
        for (int i = 0; i < num_writes; i++) begin
            tr = apb_transaction::type_id::create("tr");
            

            start_item(tr);
            if(!tr.randomize() with {
                write == 1'b1;         //force write constraint
                addr >= 12'h100;       
                addr <= 12'h1FC;       
                addr[1:0] == 2'b00;    
            }) `uvm_fatal("RAM_SEQ", "Write Randomization Failed");
            finish_item(tr);
        end

        // Random Reads
        for (int i = 0; i < num_reads; i++) begin
            tr = apb_transaction::type_id::create("tr");
            

            start_item(tr);
            if(!tr.randomize() with {
                write == 1'b0;         // Force Read constraint
                addr >= 12'h100;
                addr <= 12'h1FC;
                addr[1:0] == 2'b00; 
            }) `uvm_fatal("RAM_SEQ", "Read Randomization Failed");
            finish_item(tr);
        end

        `uvm_info("RAM_SEQ", "Scratch RAM Sequence Completed!", UVM_LOW)
    endtask
endclass

class apb_fifo_sequence extends uvm_sequence#(apb_transaction);
    `uvm_object_utils(apb_fifo_sequence)

    function new(string name = "apb_fifo_sequence");
        super.new(name);
    endfunction

    virtual task body();
        apb_transaction tr;

        `uvm_info("FIFO_SEQ", "Starting FIFO Sequence...", UVM_LOW)

        // Enabling the FIFO Block
        // Writing 1 to CTRL.FIFO_BLOCK_EN (Bit 2) at Address 0x000
        `uvm_info("FIFO_SEQ", "Enabling FIFO via CTRL register", UVM_LOW)
        read_write(1, 12'h000, 32'h0000_0004, 4'b1111);

        // Underflow Test
        `uvm_info("FIFO_SEQ", "Testing Underflow (Read while empty)", UVM_LOW)
        read_write(0, 12'h020, 32'h0000_0000, 4'b0000);

        // Filling the FIFO (Pushing 8 items)
        `uvm_info("FIFO_SEQ", "Pushing 8 items to fill the FIFO", UVM_LOW)
        for (int i = 0; i < 8; i++) begin
            tr = apb_transaction::type_id::create("tr");
            start_item(tr);
            if(!tr.randomize() with {
                write == 1'b1;         // Write operation
                addr  == 12'h020;      // FIFO_DATA address
                strb  == 4'b1111;      // Only 4'b1111 is legal for FIFO writes
            }) `uvm_fatal("FIFO_SEQ", "Randomization Failed on FIFO Push");
            finish_item(tr);
        end

        // Checking FULL Flag and Level
        // Reading FIFO_STATUS (0x024)
        `uvm_info("FIFO_SEQ", "Checking FIFO_STATUS for FULL flag", UVM_LOW)
        read_write(0, 12'h024, 32'h0000_0000, 4'b0000);

        // Overflow Test
        // Attempting to write one more item to a full FIFO
        `uvm_info("FIFO_SEQ", "Testing Overflow (Write while full)", UVM_LOW)
        read_write(1, 12'h020, 32'hAABBCCDD, 4'b1111);

        // Drain the FIFO (Pop 8 items)
        `uvm_info("FIFO_SEQ", "Popping 8 items to drain the FIFO", UVM_LOW)
        for (int i = 0; i < 8; i++) begin
            read_write(0, 12'h020, 32'h0000_0000, 4'b0000);
        end

        // Check EMPTY Flag and Level
        // Reading FIFO_STATUS (0x024)
        `uvm_info("FIFO_SEQ", "Checking FIFO_STATUS for EMPTY flag", UVM_LOW)
        read_write(0, 12'h024, 32'h0000_0000, 4'b0000);

        // Disable the FIFO Block
        // Clearing CTRL.FIFO_BLOCK_EN (Bit 2) back to 0
        `uvm_info("FIFO_SEQ", "Disabling FIFO via CTRL register", UVM_LOW)
        read_write(1, 12'h000, 32'h0000_0000, 4'b1111);

        // Disabled Access Test
        // Attempting to write to FIFO_DATA while the block is disabled
        `uvm_info("FIFO_SEQ", "Testing disabled FIFO block access", UVM_LOW)
        read_write(1, 12'h020, 32'hBAD0BAD0, 4'b1111);

        `uvm_info("FIFO_SEQ", "FIFO Sequence Completed!", UVM_LOW)
    endtask

    task read_write(bit write_f, bit [11:0] addr_f, bit [31:0] wdata_f, bit[3:0] strb_f);
        apb_transaction tr;
        tr = apb_transaction::type_id::create("tr");
        
        start_item(tr);
        tr.write = write_f;
        tr.addr = addr_f;
        tr.wdata = wdata_f;
        tr.strb = strb_f;
        finish_item(tr); 
    endtask

endclass

class apb_timer_interrupt_sequence extends uvm_sequence#(apb_transaction);
    `uvm_object_utils(apb_timer_interrupt_sequence)

    function new(string name = "apb_timer_interrupt_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info("TIMER_SEQ", "Starting Timer & Interrupts Sequence...", UVM_LOW)

        // Enable Timer Block
        // Writing to CTRL (0x000) to set TIMER_BLOCK_EN 

        `uvm_info("TIMER_SEQ", "Step 1: Enabling Timer Block via CTRL register", UVM_LOW)
        read_write(1, 12'h000, 32'h0000_0003, 4'b1111);

        // Enable Timer Interrupts
        // Writing to INT_EN (0x008) to enable the specific timer interrupt
        `uvm_info("TIMER_SEQ", "Step 2: Enabling Timer Interrupt in INT_EN", UVM_LOW)
        read_write(1, 12'h008, 32'h0000_0001, 4'b1111);

        // Load the Timer Countdown Value
        // Writing a test delay value (e.g., 0x20) to TIMER_LOAD (0x014)
        `uvm_info("TIMER_SEQ", "Step 3: Loading timer countdown value (0x20) into TIMER_LOAD", UVM_LOW)
        read_write(1, 12'h014, 32'h0000_0020, 4'b1111);

        // Start the Timer
        // Writing to TIMER_CTRL (0x018) to set the start/enable bit
        `uvm_info("TIMER_SEQ", "Step 4: Starting the timer via TIMER_CTRL", UVM_LOW)
        read_write(1, 12'h018, 32'h0000_0005, 4'b1111);

        // Verify Timer Status
        // Reading STATUS (0x004) to ensure the timer running status bit is active
        `uvm_info("TIMER_SEQ", "Step 5: Checking STATUS register for timer running state", UVM_LOW)
        read_write(0, 12'h004, 32'h0000_0000, 4'b0000);

        // 6. Monitor Active Countdown
        // Polling TIMER_VALUE (0x01C) briefly to observe the values decrementing
        `uvm_info("TIMER_SEQ", "Step 6: Polling TIMER_VALUE to observe countdown", UVM_LOW)
        for (int i = 0; i < 9; i++) begin
            read_write(0, 12'h01C, 32'h0000_0000, 4'b0000);
         //   #50; // Delay to allow the RTL timer to tick down
        end

        // Wait for Expiration and Check Interrupt Status
        // Reading INT_STATUS (0x00C) after allowing enough time for the timer to expire
        `uvm_info("TIMER_SEQ", "Step 7: Waiting for expiration & polling INT_STATUS", UVM_LOW)
       // #200; // Adjust this delay based on your clock period and the 0x20 load value
        read_write(0, 12'h00C, 32'h0000_0000, 4'b0000);
        read_write(0, 12'h00C, 32'h0000_0000, 4'b0000);

        // Clear the Interrupt
        // Applying the Write-One-to-Clear (W1C) logic to INT_STATUS (0x00C)
        `uvm_info("TIMER_SEQ", "Step 8: Clearing the interrupt flag (W1C) in INT_STATUS", UVM_LOW)
        read_write(1, 12'h00C, 32'h0000_0001, 4'b1111);

        // Stop the Timer & Disable the Block
        `uvm_info("TIMER_SEQ", "Step 9: Stopping timer and disabling the Timer Block", UVM_LOW)
        read_write(1, 12'h018, 32'h0000_0000, 4'b1111); // Stop Timer in TIMER_CTRL
        read_write(1, 12'h000, 32'h0000_0000, 4'b1111); // Disable Block in CTRL

        `uvm_info("TIMER_SEQ", "Timer & Interrupts Sequence Completed!", UVM_LOW)
    endtask

    // Helper task keeping consistent with your existing sequence framework
    task read_write(bit write_f, bit [11:0] addr_f, bit [31:0] wdata_f, bit[3:0] strb_f);
        apb_transaction tr;
        tr = apb_transaction::type_id::create("tr");
        
        start_item(tr);
        tr.write = write_f;
        tr.addr = addr_f;
        tr.wdata = wdata_f;
        tr.strb = strb_f;
        finish_item(tr); 
    endtask

    // //TIMER 
    // send(1, 12'h000, 32'h00000003, 4'hf); //CTRL bit[2] (TIMER_BLOCK_ENABLE) = 1, also the bit[0] GLOBAL_IRQ_EN = 1
    // send(1, 12'h008, 32'h00000001, 4'hf); //INTERUP_EN bit[0] (TIMER EXPIRTY INTERTUP) = 1
    // send(1, 12'h014, 32'h00000020, 4'hf); //TIMER LOAD = 0x20 for some delay
    // send(1, 12'h018, 32'h00000005, 4'hf); //TIMER_CTRT bit[0] (TIMER_START) = 1  and the bit[2] TIMER_IRQ_ENABLE=1.
    // send(0, 12'h004, 32'h00000000, 4'hf); //STATUS bit[1] should be high (TIMER RUNNING Bit)
    // send(0, 12'h01c, 32'h00000000, 4'hf); //TIMER_VALUE check
    // send(0, 12'h01c, 32'h00000000, 4'hf); //TIMER_VALUE check
    // send(0, 12'h01c, 32'h00000000, 4'hf); //TIMER_VALUE check
    // send(0, 12'h01c, 32'h00000000, 4'hf); //TIMER_VALUE check
    // send(0, 12'h01c, 32'h00000000, 4'hf); //TIMER_VALUE check
    // send(0, 12'h01c, 32'h00000000, 4'hf); //TIMER_VALUE check
    // send(0, 12'h004, 32'h00000000, 4'hf); //STATUS bit[1] should be low (TIMER RUNNING Bit)
    // `uvm_info("SEQ", "Waiting for interupt.", UVM_LOW)
    // send(0, 12'h00c, 32'h00000000, 4'hf); // @govind

endclass

class apb_error_sequence extends uvm_sequence#(apb_transaction);
    `uvm_object_utils(apb_error_sequence)

    function new(string name = "apb_error_sequence");
        super.new(name);
    endfunction

    virtual task body();
        `uvm_info("ERR_SEQ", "Starting Error Handling Sequence (PSLVERR Generation)...", UVM_LOW)

        // 1. Undefined Address Access
        // Accessing an address outside valid register (0x000-0x024) and RAM (0x100-0x1FC) ranges
        `uvm_info("ERR_SEQ", "Step 1: Write to undefined address (e.g., 0x050)", UVM_LOW)
        read_write(1, 12'h050, 32'hDEADBEEF, 4'b1111);

        // 2. Write to Read-Only Registers
        `uvm_info("ERR_SEQ", "Step 2: Write to Read-Only STATUS register (0x004)", UVM_LOW)
        read_write(1, 12'h004, 32'hFFFFFFFF, 4'b1111);

        `uvm_info("ERR_SEQ", "Step 3: Write to Read-Only TIMER_VALUE register (0x01C)", UVM_LOW)
        read_write(1, 12'h01C, 32'hFFFFFFFF, 4'b1111);

        `uvm_info("ERR_SEQ", "Step 4: Write to Read-Only FIFO_STATUS register (0x024)", UVM_LOW)
        read_write(1, 12'h024, 32'hFFFFFFFF, 4'b1111);

        // 3. Unaligned Scratch RAM Address
        // RAM addresses must be word-aligned (bottom two bits == 2'b00)
        `uvm_info("ERR_SEQ", "Step 5: Write to unaligned RAM address (0x101)", UVM_LOW)
        read_write(1, 12'h101, 32'hAABBCCDD, 4'b1111);

        // 4. FIFO Access While Disabled
        // Ensure CTRL.FIFO_BLOCK_EN is 0, then attempt a read/write
        `uvm_info("ERR_SEQ", "Step 6: Disabling FIFO block and attempting access", UVM_LOW)
        read_write(1, 12'h000, 32'h0000_0000, 4'b1111);
        read_write(1, 12'h020, 32'h11112222, 4'b1111); // Should trigger PSLVERR

        // 5. Enable FIFO for remaining checks
        `uvm_info("ERR_SEQ", "Step 7: Enabling FIFO via CTRL register", UVM_LOW)
        read_write(1, 12'h000, 32'h0000_0004, 4'b1111);

        // 6. FIFO Read While Empty
        // FIFO was just enabled, so it is guaranteed empty
        `uvm_info("ERR_SEQ", "Step 8: Read FIFO while empty", UVM_LOW)
        read_write(0, 12'h020, 32'h0000_0000, 4'b0000);

        // 7. FIFO Write with invalid PSTRB
        // FIFO pushes require PSTRB == 4'b1111
        `uvm_info("ERR_SEQ", "Step 9: Write FIFO with invalid byte strobe (PSTRB != 1111)", UVM_LOW)
        read_write(1, 12'h020, 32'h33334444, 4'b0011);

        // 8. FIFO Write While Full
        `uvm_info("ERR_SEQ", "Step 10: Filling FIFO with 8 items to test overflow...", UVM_LOW)
        for(int i = 0; i < 8; i++) begin
            read_write(1, 12'h020, 32'hAAAA0000 + i, 4'b1111);
        end
        `uvm_info("ERR_SEQ", "Step 11: Write FIFO while full", UVM_LOW)
        read_write(1, 12'h020, 32'hBAD0BAD0, 4'b1111);

        // Clean up: Disable FIFO block again
        `uvm_info("ERR_SEQ", "Step 12: Cleanup - Disabling FIFO block", UVM_LOW)
        read_write(1, 12'h000, 32'h0000_0000, 4'b1111);

        `uvm_info("ERR_SEQ", "Error Handling Sequence Completed!", UVM_LOW)
    endtask

    // Helper task to force transactions directly without triggering sequence constraints
    task read_write(bit write_f, bit [11:0] addr_f, bit [31:0] wdata_f, bit[3:0] strb_f);
        apb_transaction tr;
        tr = apb_transaction::type_id::create("tr");
        
        start_item(tr);
        // Direct assignment bypasses randomization constraints
        tr.write = write_f;
        tr.addr  = addr_f;
        tr.wdata = wdata_f;
        tr.strb  = strb_f;
        finish_item(tr); 
    endtask

endclass

class apb_random_sequence extends uvm_sequence#(apb_transaction);
    `uvm_object_utils(apb_random_sequence)

    // Randomize the number of transactions to be between 500 and 2000
    int num_trans = 2000;

    function new(string name = "apb_random_sequence");
        super.new(name);
    endfunction

    virtual task body();
        apb_transaction tr;

        `uvm_info("RAND_SEQ", $sformatf("Starting Random Stress Sequence with %0d transactions...", num_trans), UVM_LOW)

        for (int i = 0; i < num_trans; i++) begin
            tr = apb_transaction::type_id::create("tr");
            
            start_item(tr);
            
            if(!tr.randomize()) begin
                `uvm_fatal("RAND_SEQ", "Randomization Failed in Random Stress Sequence");
            end

            finish_item(tr);
        end

        `uvm_info("RAND_SEQ", "Random Stress Sequence Completed!", UVM_LOW)
    endtask
endclass

