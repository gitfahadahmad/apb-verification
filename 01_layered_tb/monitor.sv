class monitor;
 
 generator gen;
 transaction tr;
 mailbox #(transaction)  mon2scb;
 virtual dut_if vif;


 function new(virtual dut_if vif, mailbox #(transaction) mon2scb);
  this.vif = vif;
  this.mon2scb = mon2scb;
 endfunction

task run();

  //transaction tr;
 forever begin
 @(posedge vif.pclk);
 if(vif.monitor_cb.psel && vif.monitor_cb.penable && vif.monitor_cb.pready)
 begin
    tr = new();

    tr.paddr   = vif.monitor_cb.paddr;
   // tr.psel    = vif.monitor_cb.psel;
   // tr.penable = vif.monitor_cb.penable;
    tr.pwrite  = vif.monitor_cb.pwrite;
    tr.pwdata  = vif.monitor_cb.pwdata;
    tr.prdata  = vif.monitor_cb.prdata; 

    mon2scb.put(tr);
    tr.display("MON");
  end

 end

endtask


endclass
