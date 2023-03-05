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

SELECT idnr, name, course, status 
FROM BasicInformation 
JOIN Registrations ON BasicInformation.idnr = Registrations.student
UNION
SELECT course, grade FROM Taken
WHERE BasicInformation.idnr = Taken.student
ORDER BY idnr ASC;

SELECT student, course, status
FROM Registrations
UNION
SELECT student, course, grade 
FROM Taken
ORDER BY student, course ASC;