    
-- Fungerande query för att ladda in tagna kurser för studenterna.
SELECT idnr, login, program, branch, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified, 
    (SELECT array_agg(course) FROM taken WHERE taken.student = BasicInformation.idnr) AS takenCourses,
    (SELECT array_agg(course) FROM registered WHERE registered.student = BasicInformation.idnr) AS registeredCourses
FROM BasicInformation 
JOIN PathToGraduation ON BasicInformation.idnr = PathToGraduation.student
LEFT JOIN 
    (SELECT array_agg(course), student 
    FROM Taken, BasicInformation 
    WHERE Taken.student = BasicInformation.idnr 
    GROUP BY student
    ) AS TakenCourses
ON BasicInformation.idnr = TakenCourses.student
LEFT JOIN
    (SELECT array_agg(course), student
    FROM Registered, BasicInformation
    WHERE Registered.student = BasicInformation.idnr
    GROUP BY student
    ) AS RegisteredCourses
ON BasicInformation.idnr = RegisteredCourses.student;


-- FINISHED

SELECT jsonb_build_object(
'student',idnr,
'name', name,
'login', login,
'program', program, 
'branch', branch,
'finished', (
    SELECT json_agg(jsonb_build_object(
        'course', Courses.name,
        'code',FinishedCourses.course,
        'credits',FinishedCourses.credits, 
        'grade',FinishedCourses.grade))
    FROM
        FinishedCourses
    JOIN 
        Courses
    ON 
        Courses.code = FinishedCourses.course
    WHERE 
        FinishedCourses.student = idnr),
'registered', (
    SELECT json_agg(jsonb_build_object(
        'course', Courses.name,
        'code',Registrations.course, 
        'status',Registrations.status,
        'position', WaitingList.position))
    FROM
        Registrations
    JOIN 
        Courses
    ON
        Courses.code = Registrations.course
    JOIN
        WaitingList
    ON
        Waitinglist.student = Registrations.student
        AND
        Waitinglist.course = Registrations.course
    WHERE 
        Registrations.student = idnr),
'seminarCourses',seminarCourses,
'mathCredits',mathCredits, 
'researchCredits',researchCredits, 
'totalCredits',totalCredits, 
'canGraduate',qualified) AS jsondata
FROM 
    BasicInformation 
JOIN 
    PathToGraduation 
ON 
    BasicInformation.idnr = PathToGraduation.student
WHERE 
    idnr='4444444444'
GROUP BY(Basicinformation.idnr, Basicinformation.name, BasicInformation.login, basicinformation.program, basicinformation.branch, pathtograduation.seminarcourses, pathtograduation.mathcredits, pathtograduation.researchcredits, pathtograduation.totalcredits, pathtograduation.qualified);