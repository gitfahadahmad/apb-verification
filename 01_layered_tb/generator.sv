class generator;

 transaction tr;
 mailbox #(transaction) gen2drv;
 static int num_of_tr = 5;
 event done;


 function new(mailbox #(transaction) gen2drv);
  this.gen2drv = gen2drv;
 endfunction


 task run();
 repeat(num_of_tr) 
  begin
  
    tr = new();
    void'(tr.randomize());
    gen2drv.put(tr);
    tr.display("Gen");
  end 
   $display("\nGen completed all %0d transactions", num_of_tr);
   -> done;
 endtask
endclass
