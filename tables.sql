CREATE TABLE Departments (
    name TEXT NOT NULL,
    abbreviation char(2) NOT NULL,
    PRIMARY KEY (name),
    UNIQUE(abbreviation)
);

CREATE TABLE Programs (
    name TEXT NOT NULL,
    abbreviation char(2) NOT NULL,
    PRIMARY KEY (name)
);

CREATE TABLE Branches (
    name TEXT NOT NULL,
    program TEXT NOT NULL REFERENCES Programs(name),
    PRIMARY KEY (name, program)
);

CREATE TABLE Courses (
    code char(6) NOT NULL,
    name TEXT NOT NULL,
    credits NUMERIC NOT NULL,
    department TEXT NOT NULL REFERENCES Departments(name),
    PRIMARY KEY (code)
);

CREATE TABLE Students (
    idnr char(10) NOT NULL
    CHECK (idnr SIMILAR TO '[0-9]{10}'),
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL REFERENCES Programs(name),
    PRIMARY KEY (idnr),
    UNIQUE(login),
    UNIQUE(idnr, program)
);

CREATE TABLE StudentBranches( 
    student char(10) NOT NULL,
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (student),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    FOREIGN KEY (student, program) REFERENCES Students(idnr, program)
);

CREATE TABLE LimitedCourses (
    code char(6) NOT NULL REFERENCES Courses(code),
    capacity integer NOT NULL
    CHECK (capacity > 0),
    PRIMARY KEY (code)
);

CREATE TABLE MandatoryProgram (
    course char(6) NOT NULL REFERENCES Courses(code),
    program TEXT NOT NULL REFERENCES Programs(name),
    PRIMARY KEY (course, program)
);

CREATE TABLE MandatoryBranch (
    course char(6) NOT NULL REFERENCES Courses(code),
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, program, branch),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE RecommendedBranch (
    course char(6) NOT NULL REFERENCES Courses(code),
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);


CREATE TABLE Taken (
    student char(10) NOT NULL REFERENCES Students(idnr),
    course char(6) NOT NULL REFERENCES Courses(code),
    grade char(1) NOT NULL
    CHECK (grade IN ('U', '3', '4', '5')),
    PRIMARY KEY (course, student)
);

CREATE TABLE Registered (
    student char(10) NOT NULL REFERENCES Students(idnr),
    course char(6) NOT NULL REFERENCES Courses(code),
    PRIMARY KEY (course, student)
);

CREATE TABLE WaitingList (
    student char(10) NOT NULL REFERENCES Students(idnr),
    course char(6) NOT NULL REFERENCES LimitedCourses(code),
    position SERIAL NOT NULL,
    PRIMARY KEY (course, student),
    UNIQUE(course, position)
);

CREATE TABLE DepartmentProgram (
    department TEXT NOT NULL REFERENCES Departments(name),
    program TEXT NOT NULL REFERENCES Programs(name),
    PRIMARY KEY (department, program)
);

CREATE TABLE Classifications(
    name TEXT NOT NULL PRIMARY KEY
);

CREATE TABLE Classified (
    course char(6) NOT NULL REFERENCES Courses(code),
    classification TEXT NOT NULL REFERENCES Classifications(name),
    PRIMARY KEY (course, classification)
);

CREATE TABLE Prerequisite (
    course char(6) NOT NULL,
    prerequisite char(6) NOT NULL,
    PRIMARY KEY (course, prerequisite)
)