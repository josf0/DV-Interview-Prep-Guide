#include <iostream>
using std::string;

//in c++ all members of a class are private by default
//private, public and protected are access modifiers

/*
    If you dont create a constructor then compiler will allocate a value by default
    Rules of constructor: 
        It will not have a return type
        Name of constructor class should be same as that of class name
        constructor must be public but there are scenarios where it is private
*/

/*
    Encapsulation: 
    Wrapping up data and methods grouped together under a class
    To prevent other classes from directly interacting with the data and methods of the class
    How to access the encapsulated data and methods ? 
    the only way is to use a getters and setters to access
*/

/*
    Inheritance:
    when we create our own constructor class we will loose the default constructor
    This applies to the inherited class. 
    Keep in mind that inherited classes are private by default use public 
    for accessing the methods of inherited class methods
*/

/*
    stack vs heap memory allocation:
    stack Allocation: happens automatically when we cerated an object handle
        Memory access from stack is fast
        automatically freed when the function exits so data is short live
    Heap Allocation: happens when you use new, malloc , e.t.c
        Heap access is slower
        Life time access need to manually free the memory using delete
*/

//class, object and constructor function
class Employee {
public:
    string Name;
    string Company;
    int Age;

    void IntroduceYourself() {
        std::cout << "Name -" << Name << std::endl;
        std::cout << "Company -" << Company << std::endl;
        std::cout << "Age -" << Age << std::endl;
    }
    //constructor
    Employee(string name, string company, int age) {
        Name = name;
        Company = company;
        Age = age;
    }

};

int main() {
    Employee employee1 = Employee("Saldina", "YT", 25);
    /*
        employee2.Name = "John";
        employee2.Company = "YT";
        employee2.Age = 30;
    */
    employee1.IntroduceYourself();

    Employee employee2 = Employee("John", "YT", 35);
    /*
        employee2.Name = "John";
        employee2.Company = "YT";
        employee2.Age = 30;
    */
    employee2.IntroduceYourself();

}


//Encapsulation
//the encapsulated variables are accessed and assigned using getters and setters
class Employee {
    //even without the private access modifier the default access modifier is private
private:
    string Name;
    string Company;
    int Age;
public:
    //getters and setters
    void setName(string name) {
        Name = name;
    }
    string getName() {
        return Name;
    }

    void setCompany(string company) {
        Company = company;
    }
    string getCompany() {
        return Company;
    }

    void setAge(int age) {
        if(age >= 18)
        Age = age;
    }
    int getAge() {
        return Age;
    }

    void IntroduceYourself() {
        std::cout << "Name -" << Name << std::endl;
        std::cout << "Company -" << Company << std::endl;
        std::cout << "Age -" << Age << std::endl;
    }
    //constructor
    Employee(string name, string company, int age) {
        Name = name;
        Company = company;
        Age = age;
    }

};

int main() {
    Employee employee1 = Employee("Saldina", "YT", 25);
    
    employee1.IntroduceYourself();

    Employee employee2 = Employee("John", "YT", 35);
    
    employee2.IntroduceYourself();

    employee1.Name = "chart"; //error this is not allowed use setter
    employee1.setName("chart");
    std::cout << employee1.getName() << "is" << employee1.getAge() << "years old" << std::endl;
}

//Abstract classes have a pure virtual function and the inherited class should provide implementation

class AbstractEmployee {
    virtual void AskForPromotion() = 0; //this implemented should be present in the derived class
};

class Employee : public AbstractEmployee {
private:
    string Name;
    string Company;
    int Age;
public:
    //getters and setters
    void setName(string name) {
        Name = name;
    }
    string getName() {
        return Name;
    }

    void setCompany(string company) {
        Company = company;
    }
    string getCompany() {
        return Company;
    }

    void setAge(int age) {
        if(age >= 18)
        Age = age;
    }
    int getAge() {
        return Age;
    }

    void IntroduceYourself() {
        std::cout << "Name -" << Name << std::endl;
        std::cout << "Company -" << Company << std::endl;
        std::cout << "Age -" << Age << std::endl;
    }
    //constructor
    Employee(string name, string company, int age) {
        Name = name;
        Company = company;
        Age = age;
    }

    void AskForPromotion() {
        if(Age > 30)
            std::cout << Name << "Got Promoted!" << std::endl;
        else
            std::cout << Name << " no promotion" << std::endl;
    }
};

int main() {
    Employee employee1 = Employee("Saldina", "YT", 25);
    Employee employee2 = Employee("John", "YT", 35);
    employee1.AskForPromotion(); //no promotion
    employee2.AskForPromotion(); //promoted

}


//inheritance
class AbstractEmployee {
    virtual void AskForPromotion() = 0; //this implemented should be present in the derived class
};

class Employee {
private:
    string Name;
    string Company;
    int Age;
public:
    //getters and setters
    void setName(string name) {
        Name = name;
    }
    string getName() {
        return Name;
    }

    void setCompany(string company) {
        Company = company;
    }
    string getCompany() {
        return Company;
    }

    void setAge(int age) {
        if(age >= 18)
        Age = age;
    }
    int getAge() {
        return Age;
    }

    void IntroduceYourself() {
        std::cout << "Name -" << Name << std::endl;
        std::cout << "Company -" << Company << std::endl;
        std::cout << "Age -" << Age << std::endl;
    }
    //constructor
    Employee(string name, string company, int age) {
        Name = name;
        Company = company;
        Age = age;
    }

    void AskForPromotion() {
        if(Age > 30)
            std::cout << Name << "Got Promoted!" << std::endl;
        else
            std::cout << Name << " no promotion" << std::endl;
    }
};

//developer class inherits Employee class
class Developer:public Employee {
public:
    string FavProgrammingLanguage;
    Developer(string name, string company, int age, string favProgrammingLanguage) 
        :Employee(name, company, age)
    {
        FavProgrammingLanguage = favProgrammingLanguage;
    }

    void FixBug() {
        std::cout << getName() << "Fixed bug using " << FavProgrammingLanguage << std::endl;
    }

    //If the name variable is protected or public we can still use the variable name directly
    //since it is a private i used getName() getter function
};

//another inherited class
class Teacher:Employee {
public:
    string Subject;
    void PrepareLesson() {
        std::cout << Name << " is preparing " << subject << " lesson" << std::endl;
    }

    //constructor
    Teacher(string name, string company, int age, string subject)
    
}

int main() {
    Employee employee1 = Employee("Saldina", "YT", 25);
    Employee employee2 = Employee("John", "YT", 35);
    
    Developer d = Developer("saldina", "YT", 25, "c++"); 
    d.FixBug();
    d.AskForPromotion();   
}