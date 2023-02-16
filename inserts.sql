INSERT INTO Departments VALUES ('Dep1', 'D1');
INSERT INTO Departments VALUES ('Dep2', 'D2');

INSERT INTO Programs VALUES ('Prog1', 'P1', 'D2');
INSERT INTO Programs VALUES ('Prog2', 'P2', 'D1');

INSERT INTO Branches VALUES ('Prog1','B2');
INSERT INTO Branches VALUES ('Prog1','B1');
INSERT INTO Branches VALUES ('Prog2','B1');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1', 'B2');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1', 'B1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2', 'B1');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1', 'B2');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Prog2', 'B2');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2', 'B1');

INSERT INTO Courses VALUES ('CCC111',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555',50,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');
INSERT INTO Classifications VALUES ('programming');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');


INSERT INTO MandatoryCourses VALUES ('CCC111',NULL,'Prog1');
INSERT INTO MandatoryCourses VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryCourses VALUES ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedCourses VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedCourses VALUES ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');

INSERT INTO FinishedCourses VALUES('4444444444','CCC111','5');
INSERT INTO FinishedCourses VALUES('4444444444','CCC222','5');
INSERT INTO FinishedCourses VALUES('4444444444','CCC333','5');
INSERT INTO FinishedCourses VALUES('4444444444','CCC444','5');

INSERT INTO FinishedCourses VALUES('5555555555','CCC111','5');
INSERT INTO FinishedCourses VALUES('5555555555','CCC222','4');
INSERT INTO FinishedCourses VALUES('5555555555','CCC444','3');

INSERT INTO FinishedCourses VALUES('2222222222','CCC111','U');
INSERT INTO FinishedCourses VALUES('2222222222','CCC222','U');
INSERT INTO FinishedCourses VALUES('2222222222','CCC444','U');


--Edited since we give a default value for position (current date, E.g: 2023-01-20)
--Given format was single digit integers 1 & 2
INSERT INTO WaitingList VALUES('3333333333','CCC222');
INSERT INTO WaitingList VALUES('3333333333','CCC333');
INSERT INTO WaitingList VALUES('2222222222','CCC333');
