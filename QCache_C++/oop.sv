//abstract class 
class AbstractEmployee;
    pure virtual function void ask_for_promotion();
endclass

class Employee extends AbstractEmployee;

    //make the data members private
    local string Name;
    local string Company;
    local int Age;

    //constructor 
    function new(string name, string company, int age);
        this.Name = name;
        this.Company = company; 
        this.Age = age;
    endfunction

    //getters and setters 
    function void set_name(string name);
        this.Name = name;
    endfunction
    function string get_name();
        return Name;
    endfunction

    function void set_company(string company);
        this.Company = company;
    endfunction
    function string get_company();
        return Company;
    endfunction

    function void set_age(int age);
        this.Age = age;
    endfunction
    function int get_age();
        return age;
    endfunction

    //Introduce Method
    function void display();
        $display("Name : %s", Name);
        $display("Company : %s", Company);
        $display("Age : %0d", Age);
    endfunction

    //Implementing abstract method
    virtual function void ask_for_promotion();
        if(Age > 30)
            $display("%s got promoted", Name);
        else 
            $display("%s no promotion", Name);
    endfunction
endclass

module test;
    initial begin
        Employee emp1 = new("sladina", "YT", 25);
        Employee emp2 = new("John", "YT", 35);

        emp1.display();
        emp1.ask_for_promotion();

        emp1.set_name("ALICE");
        emp1.set_company("OpenAI");
        emp1.set_age(45);

        emp1.display();
        emp1.ask_for_promotion();
    end
endmodule