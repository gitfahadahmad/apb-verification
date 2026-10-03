// class apb_transaction extends uvm_sequence_item;
//     `uvm_object_utils(apb_transaction)

//     function new(string name = "apb_transaction");
//         super.new(name);
//     endfunction

//     rand bit [11:0] addr;
//     rand bit write;
//     rand bit [31:0] wdata;
//     rand bit [3:0] strb;

//     bit [31:0] rdata;
//     bit slverr;
    

// endclass


class apb_transaction extends uvm_sequence_item;

    `uvm_object_utils(apb_transaction)

    rand bit [11:0] addr;
    rand bit        write;
    rand bit [31:0] wdata;
         bit [31:0] rdata;
    rand bit [3:0]  strb;
    bit slverr;

    
    // To ensure the word alignment 
    constraint align_c {
        addr[1:0] == 2'b00;
    }

    //Restrict addresses to valid peripheral or RAM ranges
    constraint address_range_c {
        (
            // Register space (0x000 to 0x024)
            (addr >= 12'h000 && addr <= 12'h024) || 
            // RAM space (0x100 to 0x1FC)
            (addr >= 12'h100 && addr <= 12'h1FC)
        );
    }

    // // Default byte-enable strobe to full 32-bit word access for RAM
    // constraint default_strb_c {
    //     strb == 4'b1111;
    // }

    function new(string name = "apb_transaction");
        super.new(name);
    endfunction

endclass