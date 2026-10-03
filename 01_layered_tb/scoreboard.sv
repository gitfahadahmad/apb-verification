class scoreboard;
 

 logic [31:0] expected_mem [256];
 mailbox #(transaction) mon2scb;
 int pass_count = 0;
 int fail_count = 0;
 int expected_data;
 int actual_data ;
 generator gen;
 transaction tr;  


 function new(mailbox #(transaction) mon2scb);
  this.mon2scb = mon2scb;
 endfunction

 task run();
 
  repeat(gen.num_of_tr) begin

   mon2scb.get(tr);

   if(tr.pwrite == 1)
    expected_mem[tr.paddr] = tr.pwdata;
   else begin
    expected_data = expected_mem[tr.paddr];
    actual_data = tr.prdata;

    if (expected_data == actual_data) begin
     pass_count++;
     $display("Time [%0t] Scoreboard Check Passed! expected data(ref_model) = %0d | actual_data(dut) = %0d \n" ,$time , expected_data, actual_data );
     end
     
    else /*(expected_data != actual_data)*/ begin
     fail_count++;
     $display("Time [%0t] Scoreboard Check Failed! expected data(ref_model) = %0d | actual_data(dut) = %0d \n" ,$time , expected_data, actual_data );end

  end
  
  end
 endtask

 function void report();

  $display(" Total passed checks = %0d", pass_count);
  $display(" Total failed checks = %0d", fail_count);
  if (fail_count == 0 && pass_count > 0)
  $display("=================== TEST PASSED SUCCESSFULLY ==================");
  else
  $display("============= TEST FAILED===================");

 endfunction

endclass
