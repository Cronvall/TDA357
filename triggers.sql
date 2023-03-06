CREATE OR REPLACE VIEW CourseQueuePositions AS
SELECT course, student, position AS place
FROM Waitinglist;


CREATE OR REPLACE FUNCTION register() RETURNS trigger AS $$

DECLARE Cnt INTEGER;

BEGIN

    IF (EXISTS (SELECT * FROM Registered WHERE student = NEW.student AND course = NEW.course)) THEN
        RAISE EXCEPTION 'Student is already registered to course';
    END IF;

    -- Check if student already passed the course
    IF (EXISTS (SELECT * FROM PassedCourses WHERE student = NEW.student AND course = NEW.course)) THEN
        RAISE EXCEPTION 'Student has already passed the course';
    END IF;

    -- see if course has prerequisites
    IF (EXISTS (SELECT * from Prerequisite where course = NEW.course)) THEN
        -- check if student fulfills prerquisites
        IF EXISTS (SELECT prerequisite from Prerequisite where course = NEW.course 
            EXCEPT SELECT course FROM PassedCourses WHERE PassedCourses.student = NEW.student) THEN
            RAISE EXCEPTION 'Prerequisite not fulfilled';
        END IF;
    END IF;

        -- See if course is limited
    IF (EXISTS (SELECT * FROM LimitedCourses WHERE LimitedCourses.code = NEW.course)) THEN
        
        -- count number of students registered for course, if full then insert new student into WaitingList
        IF (SELECT COUNT(*) FROM Registered WHERE course = NEW.course) >= (SELECT capacity FROM LimitedCourses WHERE code = NEW.course) THEN
            -- If new student already in waitinglist, raise exception else add to waitinglist
            IF (EXISTS (SELECT * FROM WaitingList WHERE student = NEW.student AND course = NEW.course)) THEN
                RAISE EXCEPTION 'STUDENT ALREADY IN WAITING LIST';
            ELSE
                INSERT INTO WaitingList (student, course, position) VALUES (NEW.student, NEW.course, (SELECT COUNT(place)+1 FROM CourseQueuePositions WHERE course = NEW.course));
                RETURN NULL;
            END IF;             
        END IF;
    END IF;

    INSERT INTO Registered (student, course) VALUES (NEW.student, NEW.course);

    RETURN NULL;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION unregister() RETURNS trigger AS $$

DECLARE studentID char(10) DEFAULT OLD.student;
DECLARE courseID char(6) DEFAULT OLD.course;

DECLARE tempStudent char(10);

BEGIN

        -- check if student is registered to course
    IF (EXISTS (SELECT * FROM Registered WHERE student = studentID AND course = courseID)) THEN
        -- delete student from registered
        DELETE FROM Registered WHERE student = studentID AND course = courseID;

        -- if there is a student in the waiting list, move to registered
        IF (EXISTS (SELECT * FROM WaitingList WHERE course = courseID)) THEN
        -- get tempStudent from waitinglist
        SELECT student INTO tempStudent FROM WaitingList WHERE course = courseID AND position = (SELECT MIN(position) FROM WaitingList WHERE course = courseID);
        -- delete student from waitinglist
        DELETE FROM WaitingList WHERE student = tempStudent AND course = courseID;
        -- insert student into registered
        INSERT INTO Registered (student, course) VALUES (tempStudent, courseID);
        END IF;

        -- ELSE Check if student is on waitinglist
    ELSIF (EXISTS (SELECT * FROM WaitingList WHERE student = studentID AND course = courseID)) THEN
        DELETE FROM WaitingList WHERE student = studentID AND course = courseID;
    ELSE
        RAISE EXCEPTION 'Student is not registered to the course';
    END IF;

    -- if there are more students in waitinglist update position
    IF (EXISTS (SELECT * FROM WaitingList WHERE course = courseID)) THEN
        -- update position of students in waitinglist
        UPDATE WaitingList SET position = position - 1 WHERE course = courseID;
    END IF;
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
