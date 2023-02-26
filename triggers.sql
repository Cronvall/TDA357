CREATE VIEW CourseQueuePositions AS
SELECT course, student, position AS place
FROM Waitinglist;


CREATE OR REPLACE FUNCTION register() RETURNS trigger AS $$
BEGIN

        -- check if student exist?
    IF NOT (EXISTS (SELECT * FROM Students WHERE idnr = NEW.student)) THEN
        RAISE EXCEPTION 'Student does not exist';
    END IF;
    
    -- check if course exist?
    IF NOT (EXISTS (SELECT * FROM Courses WHERE code = NEW.Course)) THEN
        RAISE EXCEPTION 'Course does not exist';
    END IF;

    -- see if student is already registered
    IF (EXISTS (SELECT * FROM Registered WHERE student = NEW.student AND course = NEW.course)) THEN
        RAISE EXCEPTION 'Student already registered';
    END IF;

    -- see if course has prerequisites
    IF (EXISTS (SELECT * from Prerequisite where prerequisite.course = NEW.course)) THEN
        -- check if student fulfills prerquisites
        RAISE EXCEPTION 'PREREQUISITE EXIST';
    END IF;

        -- See if course is limited
    IF (EXISTS (SELECT * FROM LimitedCourses WHERE LimitedCourses.code = NEW.course)) THEN
        
        -- count number of students registered for course, if full then insert new student into WaitingList
        IF (SELECT COUNT(*) FROM Registered WHERE course = NEW.course) >= (SELECT capacity FROM LimitedCourses WHERE code = NEW.course) THEN
            -- If new student already in waitinglist, raise exception else add to waitinglist
            IF (EXISTS (SELECT * FROM WaitingList WHERE student = NEW.student AND course = NEW.course)) THEN
                RAISE EXCEPTION 'STUDENT ALREADY IN WAITING LIST';
            ELSE
                INSERT INTO WaitingList (student, course) VALUES (NEW.student, NEW.course);
                RAISE NOTICE 'COURSE IS FULL, STUDENT ADDED TO WAITING LIST';
            END IF;
        ELSE
            INSERT INTO Registered (student, course) VALUES (NEW.student, NEW.course);
            RAISE NOTICE 'STUDENT REGISTERED';                
        END IF;
    END IF;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION unregister() RETURNS trigger AS $$
BEGIN

    -- check if student exist?
    IF NOT (EXISTS (SELECT * FROM Students WHERE idnr = OLD.student)) THEN
        RAISE EXCEPTION 'Student does not exist';
    END IF;
    
    -- check if course exist?
    IF NOT (EXISTS (SELECT * FROM Courses WHERE code = OLD.Course)) THEN
        RAISE EXCEPTION 'Course does not exist';
    END IF;

    -- see if student is registered
    IF NOT (EXISTS (SELECT * FROM Registered WHERE student = OLD.student AND course = OLD.course)) THEN
        RAISE EXCEPTION 'Student not registered';
    END IF;

    -- delete student from Registered
    DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;

    -- check if there are students in waitinglist
    IF (EXISTS (SELECT * FROM WaitingList WHERE course = OLD.course)) THEN
        -- get first student in waitinglist
        SELECT student AS newStudent FROM WaitingList WHERE course = OLD.course ORDER BY id LIMIT 1;
        -- delete student from waitinglist
        DELETE FROM WaitingList WHERE student = newStudent AND course = OLD.course;
        -- insert student into registered
        INSERT INTO Registered (student, course) VALUES (newStudent, OLD.course);
        RAISE NOTICE 'STUDENT REMOVED FROM WAITING LIST AND ADDED TO REGISTERED';
    END IF;

    RAISE NOTICE 'STUDENT UNREGISTERED';

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER register
    INSTEAD OF INSERT ON Registrations
    FOR EACH ROW
    EXECUTE FUNCTION register();


CREATE OR REPLACE TRIGGER unregister
    INSTEAD OF DELETE ON Registrations
    FOR EACH ROW
    EXECUTE FUNCTION unregister();