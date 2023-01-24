-- Needs to fix so that branch becomes NULL when none is found
-- In the StudentBranches table.
CREATE VIEW BasicInformation AS
SELECT idnr, name, login, Students.program, branch
FROM Students, StudentBranches
WHERE  Students.idnr = StudentBranches.student;


CREATE VIEW FinishedCourses AS
SELECT student, course, grade, credits
FROM Students, Taken, Courses
WHERE Students.idnr = Taken.student 
AND Taken.course = Courses.code;


CREATE VIEW PassedCourses AS
SELECT student, course, credits
FROM FinishedCourses
WHERE grade IN ('3','4','5');


-- TODO Registrations View

-- TODO Unread mandatory View

-- TODO PathToGraduation View