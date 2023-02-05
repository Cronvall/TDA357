CREATE TABLE Students (
idnr CHAR(10) NOT NULL
CHECK (idnr SIMILAR TO '[0-9]{10}'),
name TEXT NOT NULL,
login TEXT NOT NULL,
program TEXT NOT NULL,
PRIMARY KEY (idnr)
);

CREATE TABLE Branches (
name TEXT NOT NULL,
program TEXT NOT NULL,
PRIMARY KEY (name, program)
);

CREATE TABLE Courses (
code CHAR(6) NOT NULL PRIMARY KEY,
name TEXT NOT NULL,
credits NUMERIC NOT NULL,
department TEXT NOT NULL
);

CREATE TABLE LimitedCourses (
code CHAR(6) NOT NULL PRIMARY KEY,
capacity INT NOT NULL,
FOREIGN KEY (code) REFERENCES Courses
);


CREATE TABLE StudentBranches(
student CHAR(10) NOT NULL PRIMARY KEY,
branch TEXT NOT NULL,
program TEXT NOT NULL,
FOREIGN KEY (student) REFERENCES Students,
FOREIGN KEY (branch, program) REFERENCES Branches);


CREATE TABLE Classifications(
name TEXT NOT NULL PRIMARY KEY
);


CREATE TABLE Classified(
course CHAR(6) REFERENCES Courses,
classification TEXT REFERENCES Classifications,
PRIMARY KEY (course, classification)
);

CREATE TABLE MandatoryProgram(
course CHAR(6) REFERENCES Courses(code),
program TEXT NOT NULL,
PRIMARY KEY (course, program)
);


CREATE TABLE MandatoryBranch(
course CHAR(6) REFERENCES Courses,
branch TEXT NOT NULL,
program TEXT NOT NULL,
FOREIGN KEY (branch, program) REFERENCES Branches,
PRIMARY KEY (course, branch, program)
);


CREATE TABLE RecommendedBranch(
course CHAR(6) REFERENCES Courses,
branch TEXT NOT NULL,
program TEXT NOT NULL,
FOREIGN KEY (branch, program) REFERENCES Branches,
PRIMARY KEY(course, branch, program)
);


CREATE TABLE Registered(
student CHAR(10) REFERENCES Students NOT NULL,
course CHAR(6) REFERENCES Courses NOT NULL,
PRIMARY KEY (student, course)
);


CREATE TABLE Taken(
student CHAR(10) REFERENCES Students NOT NULL,
course CHAR(6) REFERENCES Courses NOT NULL,
grade CHAR(1) NOT NULL DEFAULT 'U',
CONSTRAINT validGrade CHECK (grade IN ('U', '3', '4', '5')),
PRIMARY KEY (student, course)
);


CREATE TABLE WaitingList(
student CHAR(10) REFERENCES Students NOT NULL,
course CHAR(6) REFERENCES LimitedCourses NOT NULL,
position SERIAL NOT NULL,
PRIMARY KEY (student, course)
);