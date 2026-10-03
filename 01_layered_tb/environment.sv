class environment;
 
 virtual dut_if vif;
 mailbox #(transaction) gen2drv;
 mailbox #(transaction) mon2scb;

 generator gen;
 driver drv;
 monitor mon;
 scoreboard scb;

 function new(virtual dut_if vif);
  this.vif = vif;
  gen2drv = new(); 
  mon2scb = new();
  gen = new(gen2drv); 
  drv = new(vif, gen2drv);
  mon = new(vif, mon2scb);
  scb = new(mon2scb);
 endfunction

 task run();
        $display("Env Resetting DUT...");
        drv.reset();
        $display("Env Reset Complete.");

        fork
         gen.run();
         drv.run();
         mon.run();
         scb.run();
        join_none

    wait(gen.done.triggered);
    //#100;
    #(gen.num_of_tr * 30 +20);

    scb.report();

 endtask



endclass
