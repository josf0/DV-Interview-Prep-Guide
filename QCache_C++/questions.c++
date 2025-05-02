/*
    stack vs heap memory allocation:
    stack Allocation: happens automatically when we cerated an object handle
        Memory access from stack is fast
        automatically freed when the function exits so data is short live
    Heap Allocation: happens when you use new, malloc , e.t.c
        Heap access is slower
        Life time access need to manually free the memory using delete
*/

Myclass obj; //stack allocaiton

MyClass* obj = new MyClass();  // heap allocation
// use obj
delete obj;  // manually free memory

//Name hiding

    class Base {
    public:
        void greet() {
            cout << "Hello from Base" << endl;
        }
    };
    
    class Derived : public Base {
    public:
        void greet(string name) {
            cout << "Hello, " << name << endl;
        }
    };
    
    int main() {
        Derived d;
        d.greet("Alice");  // (1) Hello Alice
        d.greet();         // (2) compilation error 
    }

/*
    unlike c++ the sv doesn't call base constructor automatically it need to 
    use super.new() to call the base constructor inside the derived class constructor

*/

    class Base;
            function new();
                $display("Base constructor");
                greet();  // virtual
            endfunction

            virtual function void greet();
                $display("Base says hello");
            endfunction
        endclass

        class Mid extends Base;
            function new();
                $display("Mid constructor"); // ❌ super.new() is missing
            endfunction

            virtual function void greet();
                $display("Mid says hello");
            endfunction
        endclass

        class Final extends Mid;
            function new();
                $display("Final constructor"); // ❌ super.new() is missing
            endfunction

            function void greet();
                $display("Final says hello");
            endfunction
        endclass

        module test;
        initial begin
            Final f = new();
            f.greet();
        end
    endmodule