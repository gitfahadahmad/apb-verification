class transaction;

  bit pclk;
  bit rst_n;

  randc bit [31:0] paddr;
  bit psel;
  bit penable;
  rand bit pwrite;
  rand bit [31:0] pwdata;
  bit pready;
  bit [31:0] prdata;
  static int id;

  constraint address_constraint  {paddr >= 0; paddr<= 255;}
  constraint read_write { pwrite dist { pwrite == 1 := 50, pwrite == 0 := 50 }; }

 function new();
  id++;
 endfunction

 function void display(string tag);
    $display("time [%0t] [%0s] |Transaction # %0d is generated. | paddr = %0d | pwrite = %0b | pwdata = %0d | prdata = %0d" ,
   $time,tag, id, paddr, pwrite, pwdata, prdata);
 endfunction

endclass
