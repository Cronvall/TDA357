CREATE TABLE Students (
idnr CHAR(10) NOT NULL,
name TEXT NOT NULL,
login TEXT NOT NULL,
program TEXT NOT NULL,
PRIMARY KEY (idnr)
);

CREATE TABLE Branches (
name TEXT NOT NULL,
program TEXT NOT NULL,
PRIMARY KEY(name, program),
CONSTRAINT unique_NP UNIQUE (name, program)
);

CREATE TABLE Courses (
code CHAR(6) NOT NULL,
name TEXT NOT NULL,
credits NUMERIC NOT NULL,
department TEXT NOT NULL,
PRIMARY KEY (code)
);

CREATE TABLE LimitedCourses (
code CHAR(6) NOT NULL,
capacity INT NOT NULL,
PRIMARY KEY (code),
FOREIGN KEY (code) REFERENCES Courses(code)
);


CREATE TABLE StudentBranches(
student CHAR(10) NOT NULL,
branch TEXT NOT NULL,
program TEXT NOT NULL,
FOREIGN KEY (student) REFERENCES Students (idnr),
FOREIGN KEY (branch, program) REFERENCES Branches (name, program),
PRIMARY KEY (student, branch, program)
);


CREATE TABLE Classifications(
name TEXT PRIMARY KEY NOT NULL
);


CREATE TABLE Classified(
course CHAR(6) REFERENCES Courses(code) NOT NULL,
classification TEXT REFERENCES Classifications(name) NOT NULL,
PRIMARY KEY (course, classification)
);

CREATE TABLE MandatoryProgram(
course CHAR(6) REFERENCES Courses(code) NOT NULL,
program TEXT NOT NULL,
PRIMARY KEY (course, program)
);


CREATE TABLE MandatoryBranch(
course CHAR(6) NOT NULL,
branch TEXT NOT NULL,
program TEXT NOT NULL,
FOREIGN KEY (course) REFERENCES Courses (code),
FOREIGN KEY (branch, program) REFERENCES Branches (name, program),
PRIMARY KEY (course, branch, program)
);


-- TODO same as above
CREATE TABLE RecommendedBranch(
course CHAR(6) REFERENCES Courses(code) NOT NULL,
branch TEXT REFERENCES Branches(name) NOT NULL,
program TEXT REFERENCES Branches(program) NOT NULL,
PRIMARY KEY(course, branch, program)
);


CREATE TABLE Registered(
student CHAR(10) REFERENCES Students(idnr) NOT NULL,
course CHAR(6) REFERENCES Courses(code) NOT NULL,
PRIMARY KEY (student, course)
);


CREATE TABLE Taken(
student CHAR(10) REFERENCES Students(idnr) NOT NULL,
course CHAR(6) REFERENCES Courses(code) NOT NULL,
grade CHAR(1) DEFAULT 'U',
CONSTRAINT validGrade CHECK (grade IN ('U', '3', '4', '5')),
PRIMARY KEY (student, course)
);

CREATE TABLE WaitingList(
student CHAR(10) REFERENCES Students(idnr) NOT NULL,
course CHAR(6) REFERENCES LimitedCourses(code) NOT NULL,
position DATE DEFAULT CURRENT_DATE,
PRIMARY KEY (student, course)
);