CREATE TABLE Departments AS (
    name TEXT NOT NULL,
    abbreviation char(2) NOT NULL,
CONSTRAINT PK_Department PRIMARY KEY (name, abbreviation)
);

CREATE TABLE Programs AS (
    name TEXT NOT NULL,
    abbreviation char(4) NOT NULL,
    department_ab TEXT NOT NULL REFERENCES Departments(abbreviation)
CONSTRAINT PK_Program PRIMARY KEY name
);

CREATE TABLE Course (
    code char(6) NOT NULL PRIMARY KEY,
    credits NUMERIC NOT NULL,
    department TEXT NOT NULL,
    CONSTRAINT FK_Course_Department
        FOREIGN KEY (department, abbreviation)
        REFERENCES Departments(name, abbreviation)
);

CREATE TABLE Branches (
    programName TEXT NOT NULL,
    name TEXT NOT NULL,
CONSTRAINT PK_Branch PRIMARY KEY (programName, name)
);

CREATE TABLE Students (
    idnr char(10) NOT NULL
    CHECK (idnr SIMILAR TO '[0-9]{10}'),
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL REFERENCES Programs(name),
    branch TEXT NOT NULL REFERENCES Branches(name),
PRIMARY KEY (idnr)
);

CREATE TABLE MandatoryCourses (
    course char(6) NOT NULL,
    branch TEXT,
    program TEXT NOT NULL,
    CONSTRAINT FK_MandatoryCourse_Branches
        FOREIGN KEY (program, branch)
        REFERENCES Branches(programName, name),
    CONSTRAINT PK_MandatoryCourse PRIMARY KEY (course, branch, program)
);

CREATE TABLE RecommendedCourses (
    course char(6) NOT NULL REFERENCES Courses(code),
    branch TEXT NOT NULL REFERENCES Branches(name),
    program TEXT NOT NULL REFERENCES Programs(name),
    CONSTRAINT PK_RecommendedCourses PRIMARY KEY (branch, program)
);

CREATE TABLE LimitedCourses (
    course char(6) NOT NULL,
    capacity integer NOT NULL
    CHECK (capacity > 0),
    CONSTRAINT FK_LimitedCourse
        FOREIGN KEY course
        REFERENCES Courses(course),
    CONSTRAINT PK_LimitedCourse PRIMARY KEY course
);

CREATE TABLE FinishedCourses (
    course char(6) NOT NULL REFERENCES Courses(code),
    student char(10) NOT NULL REFERENCES Students(idnr),
    grade, char(1) NOT NULL
    CHECK (grade IN ('U', '3', '4', '5')),
    CONSTRAINT PK_FinishedCourse PRIMARY KEY (course, student)
);

CREATE TABLE Registered (
    course char(6) NOT NULL REFERENCES Courses(code),
    student char(10) NOT NULL REFERENCES Students(idnr)
    CONSTRAINT PK_Registered PRIMARY KEY (course, student)
);

CREATE TABLE WaitingList (
    course char(6) NOT NULL REFERENCES Courses(code),
    student char(10) NOT NULL REFERENCES Students(idnr),
    position SERIAL NOT NULL,
    CONSTRAINT PK_WaitingList PRIMARY KEY (course, student)
);

CREATE TABLE DepartmentPrograms (
    departmentName TEXT NOT NULL REFERENCES Department(name),
    programName TEXT NOT NULL REFERENCES Programs(name),
    CONSTRAINT PK_DepartmentPrograms PRIMARY KEY (departmentName, programName)
);

CREATE TABLE Classifications(
classification TEXT NOT NULL PRIMARY KEY
);

CREATE TABLE Classified (
    course char(6) NOT NULL REFERENCES Courses(code),
    classification TEXT NOT NULL REFERENCES Classified(classification),
    CONSTRAINT PK_Classifications PRIMARY KEY (course, classification)
);