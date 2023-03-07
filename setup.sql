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

INSERT INTO Programs VALUES ('Prog1','P1');
INSERT INTO Programs VALUES ('Prog2','P2');

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Departments VALUES ('Dep1','D1');
INSERT INTO Departments VALUES ('Dep2','D2');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Prog2');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');
INSERT INTO Students VALUES ('7777777777','Nx','ls7','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);
INSERT INTO LimitedCourses VALUES ('CCC111',5);

INSERT INTO Prerequisite VALUES ('CCC444','CCC333');

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');


INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');
INSERT INTO StudentBranches VALUES ('5555555555','B1','Prog2');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');
INSERT INTO Registered VALUES ('6666666666','CCC555');

INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');

INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');

INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');

INSERT INTO Taken VALUES('7777777777','CCC333','3');

INSERT INTO WaitingList VALUES('3333333333','CCC222',1);
INSERT INTO WaitingList VALUES('3333333333','CCC333',1);
INSERT INTO WaitingList VALUES('2222222222','CCC333',2);


CREATE VIEW BasicInformation AS
SELECT idnr, name, login, Students.program AS program, branch
FROM Students 
LEFT JOIN StudentBranches
ON Students.idnr = StudentBranches.student;


CREATE VIEW FinishedCourses AS
SELECT student, course, grade, credits
FROM Students, Taken, Courses
WHERE Students.idnr = Taken.student
AND Taken.course = Courses.code;


CREATE VIEW PassedCourses AS
SELECT student, course, credits
FROM FinishedCourses
WHERE grade IN ('3','4','5');


CREATE OR REPLACE VIEW Registrations AS
SELECT student, course, 'registered' AS status 
FROM Students, Registered
WHERE Students.idnr = Registered.student
UNION
Select student, course, 'waiting' AS status
FROM Students, Waitinglist
WHERE Students.idnr = Waitinglist.student
ORDER BY course,student ASC;


CREATE VIEW UnreadMandatory AS
SELECT idnr AS student, course
FROM BasicInformation
JOIN MandatoryProgram
ON BasicInformation.program = MandatoryProgram.program
UNION
SELECT idnr AS student, course
FROM BasicInformation
JOIN MandatoryBranch
ON BasicInformation.program = MandatoryBranch.program
AND BasicInformation.branch = MandatoryBranch.branch
EXCEPT
SELECT student, course
FROM BasicInformation
JOIN PassedCourses
ON BasicInformation.idnr = PassedCourses.student;

-- TODO PathToGraduation View

CREATE OR REPLACE VIEW PathToGraduation AS
WITH MathCredits AS (
    SELECT student, SUM(PassedCourses.credits) FILTER (WHERE Classified.classification = 'math') AS mathCredits
    FROM PassedCourses
    LEFT JOIN Classified
    ON PassedCourses.course = Classified.course
    GROUP BY (PassedCourses.student)
), ResearchCredits AS (
    SELECT student, SUM(PassedCourses.credits) FILTER (WHERE Classified.classification = 'research') AS researchCredits
    FROM PassedCourses
    LEFT JOIN Classified
    ON PassedCourses.course = Classified.course
    GROUP BY (PassedCourses.student)
), SeminarCourses AS (
    SELECT student, COUNT(PassedCourses.credits) FILTER (WHERE Classified.classification = 'seminar') AS seminarCourses
    FROM PassedCourses
    LEFT JOIN Classified
    ON PassedCourses.course = Classified.course
    GROUP BY (PassedCourses.student)
), RecommendedCredits AS (
    SELECT student, PassedCourses.credits AS credits
    FROM BasicInformation
    JOIN RecommendedBranch
    ON BasicInformation.branch = RecommendedBranch.branch
    AND BasicInformation.program = RecommendedBranch.program
    JOIN PassedCourses
    ON BasicInformation.idnr = PassedCourses.student
    AND RecommendedBranch.course = PassedCourses.course
)
SELECT
    idnr AS student,
    COALESCE(SUM(PassedCourses.credits), 0) AS totalCredits,
    COUNT(DISTINCT UnreadMandatory.course) AS mandatoryLeft,
    COALESCE(MathCredits.mathCredits, 0) AS mathCredits,
    COALESCE(researchCredits, 0) AS researchCredits,
    COALESCE(seminarCourses, 0) AS seminarCourses,
    CASE
        WHEN COUNT(UnreadMandatory.course) = 0
        AND mathCredits >= 20
        AND researchCredits >= 10
        AND seminarCourses >= 1
        AND RecommendedCredits.credits >= 10
    THEN TRUE
    ELSE FALSE
    END AS qualified

FROM 
    BasicInformation
LEFT JOIN 
    PassedCourses
ON BasicInformation.idnr = PassedCourses.student
LEFT JOIN
    UnreadMandatory
ON BasicInformation.idnr = UnreadMandatory.student
LEFT JOIN
    MathCredits
ON BasicInformation.idnr = MathCredits.student
LEFT JOIN
    ResearchCredits
ON BasicInformation.idnr = ResearchCredits.student
LEFT JOIN
    SeminarCourses
ON BasicInformation.idnr = seminarCourses.student
LEFT JOIN
    RecommendedCredits
ON BasicInformation.idnr = RecommendedCredits.student

GROUP BY (BasicInformation.idnr, MathCredits.mathCredits, researchCredits, seminarCourses, RecommendedCredits.credits)
ORDER BY idnr ASC;