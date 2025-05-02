class Employee{
public:
    string Name;
    string Company;
    int Age;

    void IntroduceYourself() {
        std::cout << "Name -" << Name << std::endl;
        std::cout << "Company -" << Company << std::endl;
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

    Employee employee2 = Employee("Charan", "YT", 35);

    return 0;
}