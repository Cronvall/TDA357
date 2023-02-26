


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
            -- check if course is full
            RAISE EXCEPTION 'COURSE IS LIMITED';
        ELSE RAISE EXCEPTION 'COURSE IS UNLIMITED';
        END IF;

    END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER register
    INSTEAD OF INSERT ON Registrations
    FOR EACH ROW
    EXECUTE FUNCTION register();