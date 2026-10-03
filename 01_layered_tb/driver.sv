class driver;
 
 generator gen;
 mailbox #(transaction) gen2drv;
 virtual dut_if vif;

 function new(virtual dut_if vif, mailbox #(transaction) gen2drv);
  this.gen2drv = gen2drv;
  this.vif = vif;
  endfunction
 
 task reset();

  vif.master_cb.psel <= '0;  
  vif.master_cb.penable <= '0;
  vif.master_cb.paddr <= '0;
  vif.master_cb.pwrite <= '0;
  vif.master_cb.pwdata <= '0;

  wait(vif.rst_n == 1'b1);
  @(posedge vif.pclk);

 endtask


 task drive(transaction tr);

 
    @(posedge vif.pclk); //setup stage 1st clock 

      vif.master_cb.psel    <= 1'b1;
      vif.master_cb.penable <= 1'b0;

      vif.master_cb.paddr   <= tr.paddr;
      vif.master_cb.pwrite  <= tr.pwrite;
      vif.master_cb.pwdata  <= tr.pwdata;
 
    @(posedge vif.pclk); // 2nd clock 2nd stage Access
    vif.master_cb.penable <= 1'b1;
    @(posedge vif.pclk);

    wait(vif.master_cb.pready);
    tr.prdata = vif.prdata;

    //returning back to idle state
    vif.master_cb.penable <= '0;
    vif.master_cb.psel <= '0;
 
    tr.display("Driver");
    @(posedge vif.pclk);
 endtask
 
 task run();

  transaction tr;
  //reset();

  repeat(gen.num_of_tr) begin
  gen2drv.get(tr);
  drive(tr);
  end

 endtask
endclass
