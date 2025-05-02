//In this file we will compare OOP in C++ vs SV

/*
    Key difference between c++ and sv
    Access modifiers: private, public, protected - c++
                      local , public, protected - SV
    Constructor: uses the same name as class - c++ (no return type)
                 uses the name new()
    virtual methods: uses virtual and override (optional -if the method doesn't override it will throw an error) - c++
                     same but no keyword override - SV
    Abstract class: virtual func_name() = 0; - c++
                    pure virtual function func_name(); - SV
    Instantiation - Automatic (default constructor) or dynamic - c++
                    Always uses new() method dynamic.
    static variable - Static variables should'nt be initialized inline but declare it outside
                        ex: int Myclass::count = 0; - c++
                        In sv you can directly initialize it to zero.
    stack vs heap memory allocation-

        stack Allocation: happens automatically when we cerated an object handle
            Memory access from stack is fast
            automatically freed when the function exits so data is short live
        Heap Allocation: happens when you use new, malloc , e.t.c
            Heap access is slower
            Life time access need to manually free the memory using delete

*/

//Class and object creation

    //SV
    class Animal;
        function void speak();
            $display("Animal speaks");
        endfunction
    endclass

    module tb;
        initial begin
            Animal a = new();
            a.speak(); //Output: Animal Sound
        end
    endmodule

    //c++
    class Animal {
    public:
        void speak() {
            std::cout << "Animal Sound" << std::endl;
        }
    };

    int main() {
        Animal a;
        a.speak();
    }

//Constructor

    //SV
    class Dog;
        function new();
            $display("Dog created!");
        endfunction
    endclass

    //c++
    class Dog {
    public:
        Dog() {
            std::cout << "Dog created " << std::endl;
        }
    };

//Encapsulation (Private Data + Getters/ Setters)

    class Person {
    private:
        int age;
    public:
        void setAge(int a){
            this.age = a;
        }
        int getAge() {
            return age;
        }
    };

    class Person;
        local int age;

        function void setAge(int a);
            age = a;
        endfunction

        function int getAge();
            return age;
        endfunction
    endclass

//Inheritance and Method Overriding

    class Animal {
    public:
        virtual void speak() {
            std::cout << " Animal Speaks " << std::endl;
        }
    };

    class Dog: public Animal {
    public:
        void speak() {
            std::cout << "Woof! " << std::endl;
        }
    };


    class Animal;
        virtual function void speak();
            $display(" Animal Speaks ");
        endfunction
    endclass

    class Dog extends Animal;
        function void speak();
            $display(" Woof! ");
        endfunction
    endclass

//Abstract class and pure virtual Method

    class AbstractEmployee {
    public:
        virtual void promote() = 0; //pure virtual function
    };

    class AbstractEmployee;
        pure virtual function void promote();
    endclass


//Inheritance + polymorphism

    class Shape;
            virtual function void draw();
                $display("Drawing a generic circle");
            endfunction
        endclass

        class Circle extends Shape;
            function void draw();
                $display("Drawing a Circle");
            endfunction
        endclass

        class Rectangle extends Shape;
            function void draw();
                $display("Drawing a Rectangle");
            endfunction
        endclass

        module test;
            initial begin
                Circle c = new();
                Rectangle r = new();

                Shape s1 = c;
                Shape s2 = r;

                s1.draw();
                s2.draw();
            end
    endmodule



    //c++ example

    class Shape {
        public:
            virtual void display() {
                cout << "Drawing a generic shape " << endl;
            }
        };

        class Circle: public Shape {
        public:
            void display() {
                cout << "Drawing a circle " << endl;
            }
        };

        class Rectangle : public Shape {
        public: 
            void display() {
                cout << "Drawing a rectangle " << endl;
            }
        };

        int main() {
            Circle c;
            Rectangle r;

            Shape* s1 = &c;
            Shape* s2 = &r;

            s1->draw();
            s2->draw();

            return 0;
    }

//Manual constructor + Polymorphism

    class Employee {
        public:
            string Name;
            string Company;
            int Age;

            //Manual constructor
            Employee(string name, string company, int age){
                this.Name = name;
                this.Company = company;
                this.Age = age;
            }

            virtual void work() {
                std::cout << " is doing general work " << endl;
            }
        };

        class Developer : public Employee {
        public:
            string FavLang;

            Developer(string name, string company, int age, string lang)
                :Employee(name, company, age) {
                    this.FavLang = lang;
            }

            void work() {
                cout << Name << " is writing " << FavLang << " code " << endl;
            }
        };

        class Teacher : public Employee {
        public:
            string FavSubject;

            Teacher(string name, string company, int age, string subject)
                : Employee(name, company, age) {
                    this.FavSubject = subject;
            }

            void work() {
                cout << Name << "is teaching " << FavSubject << endl;
            }
        };

        int main() {
            Developer d = Developer("Alice", "Technovo" , 28, "c++");
            Teacher t = Teacher("BOB", "High school", 35, "Math");

            Employee* e1 = &d;
            Employee* e2 = &t;

            e1->work();
            e2->work();
    }


    //similar implementation in SV

    class Employee;
        string Name;
        string Company;
        int Age;

        //manual constructor
        function new(string name, string company, int age);
            this.Name = name;
            this.Company = company;
            this.Age = age;
        endfunction

        virtual function void work();
            $display("name is %s", Name);
        endfunction
        endclass

        class Developer extends Employee;
            string FavLang;

            function new(string name, string company, int age, string lang);
                super.new(name, company, age);
                this.FavLang = lang;
            endfunction

            function void work();
                $display("%s is writing code in %s", Name, FavLang);
            endfunction
        endclass

        class Teacher extends Employee;
            string FavSubject;

            function new(stirng name, string company, int age, string lang);
                super.new(name, company, age);
                this.FavSubject = lang;
            endfunction

            function void work();
                $display("%s is teaching %s", Name, FavSubject);
            endfunction
        endclass

        module tb;
            initial begin
                Developer d = new("Alice", "Technovo", 28, "C++");
                Teacher t = new("BOB", "HighSchool", 36, "Maths");

                Employee e1 = d;
                Employee e2 = t;
                e1.work();
                e2.work();
            end
    endmodule


//static variable

    class Myclass;
        static int count;

        //constructor
        function new();
            count++;
            $display("Total Objects created: %0d", count);
        endfunction

        function void show_count();
            $display("Total objects created: %0d", count);
        endfunction
        endclass

        module test;
        initial begin
            Myclass a = new();
            Myclass b = new();
            Myclass c = new();

            a.show_count();
            b.show_count();
            c.show_count();
        end
    endmodule

    class Myclass {
        public: 
            static  int count;

            //constructor 
            Myclass() {
                count++;
                cout << "Total objects created: " << count << endl;
            }

            void display() {
                cout << "Total objects created with display method " << count << endl;
            }
        };
        int Myclass::count = 0;
        int main() {
            Myclass a = Myclass();
            Myclass b = Myclass();
            Myclass c = Myclass();

            a.display();
            b.display();
            c.display();
    }

//static variable vs static const variable

    class Sensor;
        static int sensor_count; //we can also allocate here or in module
        static const int MAX_SENSOR = 3;

        //constructor
        function new();
            if(sensor_count < MAX_SENSOR) begin
                sensor_count++;
                $display("Sensor cerated. Total value is %0d", sensor_count);
            end
            else 
                $display("Max sensors reached %0d", MAX_SENSOR);
        endfunction

        //display function
        function void display_count();
            $display("Total Sensors: %0d", sensor_count);
        endfunction
        endclass

        module tb;
        initial begin
            Sensor::sensor_count = 1; //since it is not static const

            Sensor s1 = new(); //2
            Sensor s2 = new(); //count = 3
            Sensor s3 = new();
            Sensor s4 = new();

            s1.display_count();
        end
    endmodule

    class Sensor {
        public:
            static int sensor_count;
            static const int MAX_SENSORs = 3;

            //constructor 
            Sensor() {
                if(sensor_count < MAX_SENSORs) {
                    sensor_count++;
                    cout << "Sensor created. Total = " << sensor_count << endl;
                }
                else {
                    cout << "Max sensors reached" << MAX_SENSORs << endl;
                }
            }

            void display_count() {
                cout << "Total Sensors: " << sensor_count << endl;
            }
        };

        int Sensor::sensor_count = 0;

        int main() {
        Sensor s1 = Sensor();
        Sensor s2 = Sensor();
        Sensor s3 = Sensor();

        s1.display_count();
        return 0;
    }

