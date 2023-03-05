DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO CURRENT_USER;

\ir tables.sql
\ir inserts.sql
\ir views.sql
\i triggers.sql

--TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('4444444444', 'CCC444'); 

--TEST #2: Register for a limited course that is not full.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('4444444444', 'CCC555'); 

--TEST #2: Register for a limited course that is full.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('4444444444', 'CCC222'); 

--TEST #3: Register an already registered student.
-- EXPECTED OUTCOME: Fail
--INSERT INTO Registrations VALUES ('2222222222', 'CCC222'); 

-- TEST #4: Unregister from an unlimited course. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111';

--TEST #: Register a student to a course where it did not fulfill prerequisites.
-- EXPECTED OUTCOME: Fail
-- INSERT INTO Registrations VALUES ('5555555555', 'CCC444');

--TEST #: Register a student to a limited course where it did not fulfill prerequisites.
-- EXPECTED OUTCOME: Fail
-- INSERT INTO Registrations VALUES ('5555555555', 'CCC444');

-- TEST #7: Remove a student from registration (with students in waitinglist)
-- EXPECTED OUTCOME: Pass
-- DELETE FROM Registrations WHERE student = '5555555555' AND course = 'CCC333';