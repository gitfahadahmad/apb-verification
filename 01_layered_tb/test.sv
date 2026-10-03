class test;
 
 environment env;
 virtual dut_if vif;

 function new(virtual dut_if vif);
  this.vif = vif;
  env = new(vif);
 endfunction

 task run();
  $display("======Starting the Test============");
  env.gen.num_of_tr = 1024;
  env.run();

  
  $display("======Test Completed============");
  $finish;

 endtask




endclass
