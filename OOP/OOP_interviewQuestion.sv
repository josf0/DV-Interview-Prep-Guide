/*
A base class has an init function and one child class also has an init function. 
What can you do if you want the child class to execute the base class' init function?
*/

class Base;
    function new();
      $display("Base class constructor");
    endfunction
  endclass
  
  class Child extends Base;
    function new();
      super.new(); // Calling base class constructor
      $display("Child class constructor");
    endfunction
  endclass
  
  /*
  Base class constructor  
  Child class constructor
  */
  
  //////////////////////////////////////////////////////////////////////////////

  