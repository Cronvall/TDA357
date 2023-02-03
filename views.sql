CREATE VIEW BasicInformation AS
SELECT idnr, name, login, Students.program, branch
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


-- TODO Registrations View

CREATE VIEW Registrations AS
Select student, course, 'registered' AS status 
FROM Students, Registered
WHERE Students.idnr = Registered.student
UNION
Select student, course, 'waiting' As status
FROM Students, Waitinglist
WHERE Students.idnr = Waitinglist.student;


-- TODO Unread mandatory View


-- TODO PathToGraduation View