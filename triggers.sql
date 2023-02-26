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

    -- check if the course is a limited course
    IF (EXISTS (SELECT * FROM LimitedCourses WHERE LimitedCourses.code = OLD.course)) THEN
        -- check if there are students in waitinglist
        IF (EXISTS (SELECT * FROM WaitingList WHERE course = OLD.course)) THEN

            DECLARE nextStudent char(10);

            -- get first student in waitinglist
            SELECT student INTO nextStudent FROM WaitingList WHERE course = OLD.course AND postion = 1;
            -- delete student from waitinglist
            DELETE FROM WaitingList WHERE student = nextStudent AND course = OLD.course;
            -- insert student into registered
            INSERT INTO Registered (student, course) VALUES (nextStudent, OLD.course);
            RAISE NOTICE 'STUDENT REMOVED FROM WAITING LIST AND ADDED TO REGISTERED';

            --Update the position for remainging students in waitinglist for the course
            UPDATE WaitingList SET position = position - 1 WHERE course = OLD.course AND position > 1;
            RAISE NOTICE 'WAITINGLIST POSITION UPDATED';
        END IF;
    ELSE --Case of unlimited course
        -- delete student from Registered
        DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
        RAISE NOTICE 'STUDENT UNREGISTERED';
    END IF;

    RAISE NOTICE 'STUDENT UNREGISTERED';

    RETURN NULL;

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