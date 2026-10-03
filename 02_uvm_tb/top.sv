timeunit 1ns;
timeprecision 1ns;

module top;
    `include "uvm_macros.svh"
    import uvm_pkg::*;
    import apb_pkg::*;

    logic clk;

    initial begin clk = 0;
    forever #5 clk= ~clk; end

    apb_if vif(.PCLK(clk));
    
    apb_peripheral  dut (
        .PCLK(vif.PCLK),
        .PRESETn(vif.PRESETn),
        .PADDR(vif.PADDR),
        .PSEL(vif.PSEL),
        .PENABLE(vif.PENABLE),
        .PWRITE(vif.PWRITE),
        .PWDATA(vif.PWDATA),
        .PSTRB(vif.PSTRB),
        .PRDATA(vif.PRDATA),
        .PREADY(vif.PREADY),
        .PSLVERR(vif.PSLVERR),
        .IRQ(vif.IRQ)
        );


    //assign vif.PREADY = 1'b1;

    initial begin
        `uvm_info("TOP", "Asserting Reset", UVM_LOW)
        vif.PRESETn = 1'b0;
        #20;
        vif.PRESETn = 1'b1;
        `uvm_info("TOP", " Reset Completed", UVM_LOW)

    end


    initial begin
        uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.*", "vif", vif);
        run_test("test");

        $finish;
    end

endmodule
