\i triggers.sql

-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
-- INSERT INTO Registrations VALUES ('4444444444', 'CCC444'); 

-- TEST #2: Register an already registered student.
-- EXPECTED OUTCOME: Fail
-- INSERT INTO Registrations VALUES ('2222222222', 'CCC333'); 


-- TEST #3: Unregister from an unlimited course. 
-- EXPECTED OUTCOME: Pass
-- DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111';

-- TEST #4: Remove a student from a waiting list (with additional students in it)
-- EXPECTED OUTCOME: Pass
-- DELETE FROM WaitingList WHERE student = '3333333333' AND course = 'CCC333';

-- TEST #5: Remove a student from a waiting list (with no additional students in it)
-- EXPECTED OUTCOME: Pass
-- DELETE FROM WaitingList WHERE student = '3333333333' AND course = 'CCC222';

-- TEST #6: Remove a student from a waiting list (student doesn't exist)
-- EXPECTED OUTCOME: Fail
-- DELETE FROM WaitingList WHERE student = '6666666666' AND course = 'CCC111';

-- TEST #7: Remove a student from registration (with students in waitinglist)
-- EXPECTED OUTCOME: Pass
-- DELETE FROM Registrations WHERE student = '5555555555' AND course = 'CCC333';