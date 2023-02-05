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


CREATE VIEW Registrations AS
SELECT student, course, 'registered' AS status 
FROM Students, Registered
WHERE Students.idnr = Registered.student
UNION
Select student, course, 'waiting' AS status
FROM Students, Waitinglist
WHERE Students.idnr = Waitinglist.student;


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
SELECT
    idnr AS student,
    COALESCE(SUM(PassedCourses.credits), 0) AS totalCredits,
    COUNT(UnreadMandatory.course) AS mandatoryLeft,
FROM 
    BasicInformation
LEFT JOIN 
    PassedCourses
ON BasicInformation.idnr = PassedCourses.student
LEFT JOIN
    UnreadMandatory
ON BasicInformation.idnr = UnreadMandatory.student
GROUP BY (BasicInformation.idnr)
ORDER BY idnr ASC;

SELECT * FROM PathToGraduation;



SELECT SUM(PassedCourses.credits) FILTER (WHERE Classified.classification = 'math') AS mathCredits
FROM PassedCourses
LEFT JOIN Classified
ON PassedCourses.course = Classified.course
GROUP BY (PassedCourses.student);

SELECT COALESCE(SUM(PassedCourses.credits), 0) AS researchCredits
FROM PassedCourses
LEFT JOIN Classified
ON PassedCourses.course = Classified.course
AND Classified.classification = 'research'
GROUP BY (PassedCourses.student);

SELECT COUNT(PassedCourses.credits) FILTER (WHERE Classified.classification = 'research') AS researchCredits
FROM PassedCourses
LEFT JOIN Classified
ON PassedCourses.course = Classified.course
GROUP BY (PassedCourses.student);

-- , mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified