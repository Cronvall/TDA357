DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO CURRENT_USER;

\ir tables.sql
\ir inserts.sql
\ir views.sql
\i triggers.sql

--TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('2222222222', 'CCC111'); 

--TEST #2: Register for a limited course that is not full.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('4444444444', 'CCC555'); 

--TEST #3: Register for a limited course that is full.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('6666666666', 'CCC333'); 

--TEST #4: Register an already registered student.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('2222222222', 'CCC222'); 

--TEST #5: Register a student that already passed the course.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('4444444444', 'CCC111');

-- TEST #6: Unregister from an unlimited course.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '6666666666' AND course = 'CCC555';

-- TEST #7: Unregister from an limited course without waitinglist.
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111';

-- TEST #8: Unregister from an limited course (with students in waitinglist). 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '3333333333' AND course = 'CCC333';

-- TEST #9: Unregister from an limited course where the student is in on the waitinglist. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '6666666666' AND course = 'CCC333';

--TEST #10: Register a student to a course where it did not fulfill prerequisites.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('1111111111', 'CCC444');

--TEST #11: Register a student to a course who fulfills prerequisites.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('7777777777', 'CCC444');

-- TEST #12: Unregister from an limited course which was overfilled. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '5555555555' AND course = 'CCC222';