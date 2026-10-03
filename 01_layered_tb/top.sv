timeunit 1ns;
timeprecision 1ns;

import apb_pkg::*;


module top;

    logic pclk, rst_n;
    dut_if dif(.pclk(pclk), .rst_n(rst_n));
    apb_slave dut (.dif(dif));

    test t1;
    initial pclk = 0;
    always #5 pclk = ~pclk;

    initial begin
    $display("============Top Reset starting==================");
        rst_n = 0;
        @(posedge pclk);
        rst_n = 1;
        @(posedge pclk);
    $display("===================Top Reset Asserted=====================");
        t1 = new(dif);
        t1.run();
        @(posedge pclk);

        $finish;
     end

    

 
 endmodule
