    
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
