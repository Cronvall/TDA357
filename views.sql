CREATE VIEW BasicInformation AS
SELECT idnr, name, login, program, branch
FROM Students; 

CREATE VIEW FinishedCoursesView AS
SELECT student, course, grade, credits
FROM FinishedCourses
LEFT JOIN Courses
ON FinishedCourses.course = Courses.code;


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
JOIN MandatoryCourse
ON BasicInformation.program = MandatoryProgram.program
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
    GROUP BY (PassedCourses.student)
), ResearchCredits AS (
    SELECT student, SUM(PassedCourses.credits) FILTER (WHERE Classified.classification = 'research') AS researchCredits
    FROM PassedCourses
    GROUP BY (PassedCourses.student)
), SeminarCourses AS (
    SELECT student, COUNT(PassedCourses.credits) FILTER (WHERE Classified.classification = 'seminar') AS seminarCourses
    FROM PassedCourses
    GROUP BY (PassedCourses.student)
), RecommendedCredits AS (
    SELECT student, PassedCourses.credits AS credits
    FROM BasicInformation
    JOIN RecommendedCourses
    ON BasicInformation.branch = RecommendedCourses.branch
    AND BasicInformation.program = RecommendedCourses.program
    JOIN PassedCourses
    ON BasicInformation.idnr = PassedCourses.student
    AND RecommendedCourses.course = PassedCourses.course
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

SELECT * FROM PathToGraduation;