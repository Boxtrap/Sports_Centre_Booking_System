-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- DROP STATEMENTS -------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

-- DROP TABLES ----------------------------------------------------------------------------------------------------------------------------------
DROP TABLE CourtParticipants;
DROP TABLE CourtBooking;
DROP TABLE Staff;
DROP TABLE Court;
DROP TABLE VitaminPlan;
DROP TABLE Vitamin;
DROP TABLE Dosage;
DROP TABLE Membership;
DROP TABLE Address;
-- DROP SEQUENCES -------------------------------------------------------------------------------------------------------------------------------
DROP SEQUENCE address_sequence; 
DROP SEQUENCE membership_sequence; 
DROP SEQUENCE staff_sequence; 
DROP SEQUENCE court_sequence;
DROP SEQUENCE court_booking_sequence;
DROP SEQUENCE dosage_sequence;
DROP SEQUENCE vitamin_sequence;
DROP SEQUENCE vitamin_plan_sequence;
-------------------------------------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- SEQUENCES -------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

-- SEQUENCE: ADDRESS ----------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE address_sequence
  START WITH 1
  INCREMENT BY 1;

-- SEQUENCE: MEMBERSHIP -------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE membership_sequence
  START WITH 1
  INCREMENT BY 1;

-- SEQUENCE: STAFF ------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE staff_sequence
  START WITH 1
  INCREMENT BY 1;

-- SEQUENCE: COURT ------------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE court_sequence
  START WITH 1
  INCREMENT BY 1;
 
-- SEQUENCE: COURT BOOKING -----------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE court_booking_sequence
  START WITH 1
  INCREMENT BY 1;
 
-- SEQUENCE: DOSAGE ------------------------------------------------------------------------------------------------------------------------------
  CREATE SEQUENCE dosage_sequence
  START WITH 1
  INCREMENT BY 1;
 
-- SEQUENCE: VITAMIN -----------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE vitamin_sequence
  START WITH 1
  INCREMENT BY 1;
 
-- SEQUENCE: VITAMIN PLAN ------------------------------------------------------------------------------------------------------------------------
CREATE SEQUENCE vitamin_plan_sequence
  START WITH 1
  INCREMENT BY 1;
  
-------------------------------------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- CREATE TABLE ----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATE TABLE: ADDRESS ------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Address (
    Address_ID NUMBER PRIMARY KEY,
    House_Number NUMBER,
    Street VARCHAR2(100),
    Postcode VARCHAR2(20)
);

-- CREATE TABLE: MEMBERSHIP ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE Membership (
    Membership_ID NUMBER PRIMARY KEY,
    Surname VARCHAR2(30),
    Forenames VARCHAR2(30),
    Age NUMBER,
    Address_ID NUMBER,
    FOREIGN KEY (Address_ID) REFERENCES Address (Address_ID)
);

-- CREATE TABLE: COURT --------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Court (
    Court_ID NUMBER PRIMARY KEY,
    Court_Number NUMBER
);

-- CREATE TABLE: STAFF --------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Staff (
    Staff_ID NUMBER PRIMARY KEY,
    Surname VARCHAR2(50),
    Forename VARCHAR2(50),
    Job_Role VARCHAR2(50),
    Address_ID NUMBER,
    FOREIGN KEY (Address_ID) REFERENCES Address(Address_ID)
);

-- CREATE TABLE: COURT BOOKING -------------------------------------------------------------------------------------------------------------------
CREATE TABLE CourtBooking (
    Court_Booking_ID NUMBER PRIMARY KEY,
    Court_ID NUMBER,
    Day NUMBER,
    Month NUMBER,
    Year NUMBER,
    Membership_ID NUMBER,
    Timeslot NUMBER,
    Participants NUMBER,
    Staff_ID NUMBER,
    FOREIGN KEY (Membership_ID) REFERENCES Membership(Membership_ID),
    FOREIGN KEY (Court_ID) REFERENCES Court(Court_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
);

-- CREATE TABLE: COURT PARTICIPANTS ---------------------------------------------------------------------------------------------------------------
CREATE TABLE CourtParticipants (
    Court_Booking_ID NUMBER,
    Membership_ID NUMBER,
    PRIMARY KEY (Court_Booking_ID, Membership_ID),
    FOREIGN KEY (Court_Booking_ID) REFERENCES CourtBooking(Court_Booking_ID),
    FOREIGN KEY (Membership_ID) REFERENCES Membership(Membership_ID)
);

-- CREATE TABLE: DOSAGE ---------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Dosage (
    Dosage_ID NUMBER PRIMARY KEY,
    Dosage NUMBER,
    Units_Per_Day NUMBER
);

-- CREATE TABLE: VITAMIN --------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Vitamin (
    Vitamin_ID NUMBER PRIMARY KEY,
    Name VARCHAR2(50),
    Description VARCHAR2(250),
    Form VARCHAR2(20)
);

-- CREATE TABLE: VITAMIN PLAN ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE VitaminPlan (
    Vitamin_Plan_ID NUMBER PRIMARY KEY,
    Membership_ID NUMBER,
    Vitamin_ID NUMBER,
    Dosage_ID NUMBER,
    Start_Day NUMBER,
    Start_Month NUMBER,
    Start_Year NUMBER,
    Finish_Day NUMBER,
    Finish_Month NUMBER,
    Finish_Year NUMBER,
    FOREIGN KEY (Membership_ID) REFERENCES Membership(Membership_ID),
    FOREIGN KEY (Vitamin_ID) REFERENCES Vitamin(Vitamin_ID),
    FOREIGN KEY (Dosage_ID) REFERENCES Dosage(Dosage_ID)
);

-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- TRIGGERS --------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------| TRIGGER: COURT BOOKING - COURT AVAILABILITY |------------------------------------------------------------------
-- Check if the court has been booked for the time slot on the required date.
CREATE OR REPLACE TRIGGER CheckCourtBooking
BEFORE INSERT ON CourtBooking
FOR EACH ROW
DECLARE
    CourtBookingCount NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO CourtBookingCount
    FROM CourtBooking CB
    WHERE CB.Court_ID = :NEW.Court_ID
      AND CB.Day = :NEW.Day
      AND CB.Month = :NEW.Month
      AND CB.Year = :NEW.Year
      AND CB.Timeslot = :NEW.Timeslot;
    IF CourtBookingCount > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Court is  booked for specified time slot.');
    END IF;
END;
/

--------------------------------| TRIGGER: COURT BOOKING - COURT PARTICIPANTS |------------------------------------------------------------------
-- Participants can only be 2 (Singles) or 4 (Doubles)
CREATE OR REPLACE TRIGGER CheckParticipants
BEFORE INSERT OR UPDATE ON CourtBooking
FOR EACH ROW
DECLARE
    InvalidParticipants EXCEPTION;
BEGIN
    IF :NEW.Participants NOT IN (2, 4) THEN
        RAISE InvalidParticipants;
    END IF;
EXCEPTION
    WHEN InvalidParticipants THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid number of participants. Only 2 (Singles) or 4 (Doubles) participants are allowed.');
END;
/

--------------------------------| TRIGGER: COURT BOOKING - COURT OPEN TIMES |--------------------------------------------------------------------
-- Check the court opening times to see if court booking is valid.
CREATE OR REPLACE TRIGGER CheckBookingTimeConstraint
BEFORE INSERT ON CourtBooking
FOR EACH ROW
DECLARE
    DayOfWeek NUMBER;
    BookingTime NUMBER;
    ErrorMessage VARCHAR2(200);
BEGIN
    -- Calculates the day of the week for the specified date.
    DayOfWeek := TO_CHAR(TO_DATE(:NEW.YEAR || '-' || :NEW.MONTH || '-' || :NEW.DAY, 'YYYY-MM-DD'), 'D');

    -- Convert the time slot to a 24-hour format and check if it's within the allowed hours based on the day of the week.
    BookingTime := TO_NUMBER(SUBSTR(:NEW.TIMESLOT, 1, 2));

    IF (DayOfWeek >= 2 AND DayOfWeek <= 6 AND BookingTime >= 9 AND BookingTime <= 20) OR
       (DayOfWeek = 7 AND BookingTime >= 11 AND BookingTime <= 16) OR
       (DayOfWeek = 1 AND BookingTime >= 12 AND BookingTime <= 15) THEN
        NULL; -- Booking is within the allowed hours
    ELSE
        ErrorMessage := 'Invalid booking time. Courts are available on ';

        CASE DayOfWeek
            WHEN 1 THEN ErrorMessage := ErrorMessage || 'Sunday (12:00 pm - 3:00 pm).';
            WHEN 2 THEN ErrorMessage := ErrorMessage || 'Monday (9:00 am - 9:00 pm).';
            WHEN 3 THEN ErrorMessage := ErrorMessage || 'Tuesday (9:00 am - 9:00 pm).';
            WHEN 4 THEN ErrorMessage := ErrorMessage || 'Wednesday (9:00 am - 9:00 pm).';
            WHEN 5 THEN ErrorMessage := ErrorMessage || 'Thursday (9:00 am - 9:00 pm).';
            WHEN 6 THEN ErrorMessage := ErrorMessage || 'Friday (9:00 am - 9:00 pm).';
            WHEN 7 THEN ErrorMessage := ErrorMessage || 'Saturday (11:00 am - 4:00 pm).';
        END CASE;

        RAISE_APPLICATION_ERROR(-20003, ErrorMessage);
    END IF;
END;
/


-- TRIGGER: COURT BOOKING - BOOKING TIME  -------------------------------------------------------------------------------------------------------
-- Checks the booking time slot is on the hour.
CREATE OR REPLACE TRIGGER CheckHourlyTimeslot
BEFORE INSERT OR UPDATE ON CourtBooking
FOR EACH ROW
DECLARE
    Hourly INTEGER;
BEGIN
    -- Extract the last two digits of the time slot to check if it's on the hour.
    Hourly := TO_NUMBER(SUBSTR(:NEW.Timeslot, -2));

    IF Hourly <> 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid time slot. Please choose a time on the hour (e.g., 1300, 1400).');
    END IF;
END;
/

-------------------------------------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- PROCEDURES ------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------| PROCEDURE: MEMBER - ADD/UPDATE/DELETE |------------------------------------------------------------------------

--------------------------------| PROCEDURE: MEMBER - ADD |--------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE AddNewMember(
    p_Surname Membership.Surname%TYPE,
    p_Forenames Membership.Forenames%TYPE,
    p_Age Membership.Age%TYPE,
    p_House_Number Address.House_Number%TYPE,
    p_Street Address.Street%TYPE,
    p_Postcode Address.Postcode%TYPE
) AS
    v_Address_ID Address.Address_ID%TYPE;
BEGIN
    -- Insert Address
    INSERT INTO Address (Address_ID, House_Number, Street, Postcode)
    VALUES (address_sequence.NEXTVAL, p_House_Number, p_Street, p_Postcode)
    RETURNING Address_ID INTO v_Address_ID;

    -- Insert Membership
    INSERT INTO Membership (Membership_ID, Surname, Forenames, Age, Address_ID)
    VALUES (membership_sequence.NEXTVAL, p_Surname, p_Forenames, p_Age, v_Address_ID);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Add New Member: Complete');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Add New Member Error: Duplicate found.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Add New Member Error ' || SQLERRM);
END AddNewMember;
/

--------------------------------| PROCEDURE: MEMBER - ADD - TEST DATA  |-------------------------------------------------------------------------
BEGIN
-- Members 1 - 10 Assigned a Court Bookings. 
    AddNewMember('Wayne', 'Bruce', 30, 1007, 'Gotham Street', 'GTHM123');
    AddNewMember('Kent', 'Clark', 36, 1938, 'Metropolis Lane', 'MET123');
    AddNewMember('Parker', 'Peter', 25, 42, 'Web Avenue', 'WEB456');
    AddNewMember('Stark', 'Tony', 45, 10880, 'Iron Street', 'IRON789');
    AddNewMember('Prince', 'Diana', 30, 30, 'Themyscira Way', 'THEMY123');
    AddNewMember('Rogers', 'Steve', 33, 45, 'Freedom Road', 'FREEDOM456');
    AddNewMember('Romanoff', 'Natasha', 38, 72, 'Spy Lane', 'SPY789');
    AddNewMember('Kent', 'Bruce', 40, 27, 'Batcave Alley', 'BAT123');
    AddNewMember('Danvers', 'Carol', 17, 7, 'Space Boulevard', 'SPACE789');
    AddNewMember('Wilson', 'Sam', 35, 25, 'Falcon Street', 'FLCN456');
    AddNewMember('Barton', 'Clint', 40, 56, 'Arrow Lane', 'ARW123'); -- Member 11 Used for Update Procedure.
    AddNewMember('Maximoff', 'Wanda', 32, 83, 'Chaos Road', 'CHAOS789');
    AddNewMember('Strange', 'Stephen', 45, 14, 'Mystic Lane', 'MSTC123');
    AddNewMember('Wade', 'Wilson', 30, 18, 'Mercenary Road', 'MRCD456');
    AddNewMember('Pym', 'Hank', 60, 62, 'Ant Lane', 'ANT123');
    AddNewMember('Van Dyne', 'Hope', 28, 37, 'Wasp Boulevard', 'WASP789');
    AddNewMember('Murdock', 'Matt', 30, 90, 'Blind Alley', 'BLND123');
    AddNewMember('Castle', 'Frank', 15, 112, 'Punishment Street', 'PUNISH789');
    AddNewMember('Graham', 'Scott', 32, 15, 'Meadow Walk', 'NP165AU');    -- Member 19 Delete
    AddNewMember('Jones', 'Jessica', 35, 15, 'Private Eye Lane', 'PRIV123');
    AddNewMember('Wilson', 'Reed', 40, 51, 'Fantastic Avenue', 'FANT123');
    AddNewMember('Richards', 'Sue', 38, 51, 'Invisible Lane', 'INVSBL789');
    AddNewMember('Storm', 'Johnny', 32, 51, 'Flame Street', 'FLAME456');
    AddNewMember('Grimm', 'Ben', 45, 51, 'Rocky Road', 'ROCKY123');
    AddNewMember('Parker', 'May', 70, 42, 'Web Avenue', 'WEB222');
    AddNewMember('Osborn', 'Norman', 16, 42, 'Green Goblin Boulevard', 'GG456');
    AddNewMember('Lehnsherr', 'Erik', 55, 83, 'Magnetic Lane', 'MAGNET789');
    AddNewMember('Xavier', 'Charles', 60, 35, 'Mutant Manor', 'MUTANT123');
    AddNewMember('Lensherr', 'Lorna', 30, 83, 'Polaris Street', 'POL789');
    AddNewMember('Summers', 'Scott', 40, 51, 'Optic Alley', 'OPTIC456');

END;
/

--------------------------------| PROCEDURE: MEMBER - UPDATE | ----------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE UpdateMember(
    p_Membership_ID Membership.Membership_ID%TYPE,
    p_Surname Membership.Surname%TYPE,
    p_Forenames Membership.Forenames%TYPE,
    p_Age Membership.Age%TYPE,
    p_House_Number Address.House_Number%TYPE,
    p_Street Address.Street%TYPE,
    p_Postcode Address.Postcode%TYPE
) AS
BEGIN
    UPDATE Address
    SET House_Number = p_House_Number,
        Street = p_Street,
        Postcode = p_Postcode
    WHERE Address_ID = (SELECT Address_ID FROM Membership WHERE Membership_ID = p_Membership_ID);
    
    UPDATE Membership
    SET Surname = p_Surname,
        Forenames = p_Forenames,
        Age = p_Age
    WHERE Membership_ID = p_Membership_ID;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Update Member ' || p_Membership_ID || ' : Complete');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END UpdateMember;
/

--------------------------------| PROCEDURE: MEMBER - UPDATE - TEST DATA | ----------------------------------------------------------------------
BEGIN
    UpdateMember(11, 'Snake', 'Solid', 45, 45, 'Dark Tunnel', '12345');
END;
/

--------------------------------| PROCEDURE: MEMBER - DELETE |-----------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE DeleteMember(p_Membership_ID Membership.Membership_ID%TYPE) AS
    v_Count NUMBER;
BEGIN
    -- Check if Member exists
    SELECT COUNT(*)
    INTO v_Count
    FROM Membership
    WHERE Membership_ID = p_Membership_ID;

    IF v_Count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Membership ID ' || p_Membership_ID || ' not found.');
        RETURN; 
    END IF;
    
    DELETE FROM Membership WHERE Membership_ID = p_Membership_ID;

    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Delete Member ' || p_Membership_ID || ': Complete');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Delete Member Error: ' || SQLERRM);
END DeleteMember;
/

--------------------------------| PROCEDURE: MEMBER - DELETE - TEST DATA | ----------------------------------------------------------------------
BEGIN
    DeleteMember(19);
END;
/

--------------------------------| PROCEDURE: STAFF - ADD/UPDATE/DELETE | ------------------------------------------------------------------------

--------------------------------| PROCEDURE: STAFF - ADD  |--------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE AddNewStaff(
    p_Surname Staff.Surname%TYPE,
    p_Forename Staff.Forename%TYPE,
    p_Job_Role Staff.Job_Role%TYPE,
    p_House_Number Address.House_Number%TYPE,
    p_Street Address.Street%TYPE,
    p_Postcode Address.Postcode%TYPE
) AS
    v_Address_ID Address.Address_ID%TYPE;
BEGIN
    -- Insert Address
    INSERT INTO Address (Address_ID, House_Number, Street, Postcode)
    VALUES (address_sequence.NEXTVAL, p_House_Number, p_Street, p_Postcode)
    RETURNING Address_ID INTO v_Address_ID;

    -- Insert Staff
    INSERT INTO Staff (Staff_ID, Surname, Forename, Job_Role, Address_ID)
    VALUES (staff_sequence.NEXTVAL, p_Surname, p_Forename, p_Job_Role, v_Address_ID);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Add Staff Member: Complete');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Add Staff Member Error: Duplicate found.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Add Staff Member Error: ' || SQLERRM);
END AddNewStaff;
/

--------------------------------| PROCEDURE: STAFF - ADD - TEST DATA |---------------------------------------------------------------------------
BEGIN
    AddNewStaff('Depp', 'Johnny', 'Trainer', 123, 'Main Street', '90210');
    AddNewStaff('Jolie', 'Angelina', 'Nutritionist', 456, 'Sunset Blvd', '90046');
    AddNewStaff('Cruise', 'Tom', 'Fitness Instructor', 789, 'Beverly Hills', '90212');
    AddNewStaff('Pitt', 'Brad', 'Physical Therapist', 1011, 'Rodeo Dr', '90210');
    AddNewStaff('Roberts', 'Julia', 'Yoga Instructor', 1213, 'Melrose Ave', '90069');
    AddNewStaff('Lawrence', 'Jennifer', 'Massage Therapist', 1415, 'Santa Monica Blvd', '90401');
    AddNewStaff('DiCaprio', 'Leonardo', 'Personal Trainer', 1617, 'Hollywood Blvd', '90028');
    AddNewStaff('Bullock', 'Sandra', 'Dietitian', 1819, 'Wilshire Blvd', '90024');
    AddNewStaff('Smith', 'Will', 'Fitness Coach', 2021, 'Pacific Coast Hwy', '90265');
    AddNewStaff('Streep', 'Meryl', 'Wellness Consultant', 2223, 'Venice Blvd', '90066');
    AddNewStaff('Damon', 'Matt', 'Mental Health Coach', 2425, 'Silver Lake Blvd', '90026');
    AddNewStaff('Cumberbatch', 'Benedict', 'Fitness Specialist', 2627, 'Abbott Kinney Blvd', '90291');
    AddNewStaff('Witherspoon', 'Reese', 'Health Educator', 2829, 'Sunset Strip', '90046');
    AddNewStaff('Hanks', 'Tom', 'Wellness Coordinator', 3031, 'Echo Park Ave', '90026');
    AddNewStaff('Johansson', 'Scarlett', 'Exercise Physiologist', 3233, 'Los Feliz Blvd', '90027');
    AddNewStaff('Hathaway', 'Anne', 'Physical Fitness Specialist', 3435, 'Fairfax Ave', '90046');  -- Staff 16 Update
    AddNewStaff('Efron', 'Zac', 'Wellness Coach', 3637, 'Hillhurst Ave', '90027');
    AddNewStaff('Portman', 'Natalie', 'Health and Wellness Instructor', 3839, 'Mulholland Dr', '90210');  -- Staff Delete
    AddNewStaff('Gosling', 'Ryan', 'Fitness Program Coordinator', 4041, 'Sunset Plaza Dr', '90069');
    AddNewStaff('Kidman', 'Nicole', 'Exercise Specialist', 4243, 'Laurel Canyon Blvd', '90046');
END;
/

--------------------------------| PROCEDURE: STAFF - UPDATE |------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE UpdateStaff(
    p_Staff_ID IN Staff.Staff_ID%TYPE,
    p_Surname IN Staff.Surname%TYPE,
    p_Forename IN Staff.Forename%TYPE,
    p_Job_Role IN Staff.Job_Role%TYPE,
    p_House_Number IN Address.House_Number%TYPE,
    p_Street IN Address.Street%TYPE,
    p_Postcode IN Address.Postcode%TYPE
) AS
BEGIN
    -- Update Staff 
    UPDATE Staff
    SET Surname = p_Surname,
        Forename = p_Forename,
        Job_Role = p_Job_Role
    WHERE Staff_ID = p_Staff_ID;

    -- Update Address 
    UPDATE Address
    SET House_Number = p_House_Number,
        Street = p_Street,
        Postcode = p_Postcode
    WHERE Address_ID = (SELECT Address_ID FROM Staff WHERE Staff_ID = p_Staff_ID);

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Update Staff Member ' || p_Staff_ID || ': Complete');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Update Staff Error: Staff ID ' || p_Staff_ID || ' not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Update Staff Error: ' || SQLERRM);
END UpdateStaff;
/

--------------------------------| PROCEDURE: STAFF - UPDATE - TEST DATA |------------------------------------------------------------------------
BEGIN
    UpdateStaff(p_Staff_ID => 16, p_Surname => 'Washington', 
    p_Forename => 'Denzel', 
    p_Job_Role => 'Undercover Police', 
    p_House_Number => 34, 
    p_Street => 'Updated Street', 
    p_Postcode => 'Updated Postcode');
END;
/ 

--------------------------------| PROCEDURE: STAFF - DELETE |------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE DeleteStaff(
    p_Staff_ID IN Staff.Staff_ID%TYPE
) AS
    v_Address_ID Address.Address_ID%TYPE;
BEGIN
    -- Check if the Staff exists
    SELECT Address_ID INTO v_Address_ID
    FROM Staff
    WHERE Staff_ID = p_Staff_ID;

    IF v_Address_ID IS NULL THEN
        DBMS_OUTPUT.PUT_LINE('Delete Staff Error: Staff ID ' || p_Staff_ID || ' not found.');
        RETURN;
    END IF;

    DELETE FROM Staff WHERE Staff_ID = p_Staff_ID;

    DELETE FROM Address WHERE Address_ID = v_Address_ID;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Delete Staff Member ' || p_Staff_ID || ': Complete');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Delete Staff Error: Staff ID ' || p_Staff_ID || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Delete Staff Member Error: ' || SQLERRM);
END DeleteStaff;
/

--------------------------------| PROCEDURE: STAFF - DELETE - TEST DATA | -----------------------------------------------------------------------
BEGIN
    DeleteStaff(p_Staff_ID => 18);
END;
/

--------------------------------| PROCEDURE: COURT - ADD/UPDATE/DELETE |-------------------------------------------------------------------------

--------------------------------| PROCEDURE: COURT - ADD |---------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE AddNewCourt(
    p_Court_Number Court.Court_Number%TYPE
) AS
BEGIN
    -- Insert new court
    INSERT INTO Court (Court_ID, Court_Number)
    VALUES (court_sequence.NEXTVAL, p_Court_Number);

    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Add Court: Complete');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Add Court Error: Duplicate Court Number.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Add Court Error: ' || SQLERRM);
END AddNewCourt;
/

--------------------------------| PROCEDURE: COURT - ADD - TEST DATA |---------------------------------------------------------------------------
BEGIN
    AddNewCourt(1);
    AddNewCourt(2);
    AddNewCourt(3);
    AddNewCourt(4);
    AddNewCourt(5);
    AddNewCourt(6);
    AddNewCourt(7);
    AddNewCourt(8);
END;
/

--------------------------------| PROCEDURE: COURT - UPDATE |------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE UpdateCourt(
    p_Court_ID IN Court.Court_ID%TYPE,
    p_Court_Number IN Court.Court_Number%TYPE
) AS
    v_Court_Count INTEGER;
BEGIN
    -- Check if the Court ID exists
    SELECT COUNT(*)
    INTO v_Court_Count
    FROM Court
    WHERE Court_ID = p_Court_ID;

    IF v_Court_Count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Court ID ' || p_Court_ID || ' does not exist.');
        RETURN;
    END IF;

    -- Update Court record
    UPDATE Court
    SET Court_Number = p_Court_Number
    WHERE Court_ID = p_Court_ID;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Update Court: Complete');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Update Court Error: Court ID ' || p_Court_ID || ' not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Update Court Error: ' || SQLERRM);
END UpdateCourt;
/

--------------------------------| PROCEDURE: COURT - UPDATE - TEST DATA | -----------------------------------------------------------------------
BEGIN
    UpdateCourt(p_Court_ID => 5, p_Court_Number => 10); 
    UpdateCourt(p_Court_ID => 6, p_Court_Number => 20);
END;
/

--------------------------------| PROCEDURE: COURT - DELETE |------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE DeleteCourt(p_Court_ID IN Court.Court_ID%TYPE) AS
    v_Court_Count NUMBER;
BEGIN
    -- Check if the Court ID exists
    SELECT COUNT(*)
    INTO v_Court_Count
    FROM Court
    WHERE Court_ID = p_Court_ID;

    IF v_Court_Count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Court ID ' || p_Court_ID || ' does not exist.');
        RETURN;
    END IF;

    DELETE FROM Court WHERE Court_ID = p_Court_ID;
    
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Delete Court ' || p_Court_ID || ': Complete');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Delete Court Error: Court ID ' || p_Court_ID || ' not found.');
    WHEN OTHERS THEN

        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Delete Court Error: ' || SQLERRM);
END DeleteCourt;
/

--------------------------------| PROCEDURE: COURT - DELETE - TEST DATA |------------------------------------------------------------------------
BEGIN 
    DeleteCourt(7); 
    DeleteCourt(8); 
END;
/

--------------------------------| PROCEDURE: COURT BOOKING - ADD/UPDATE/DELETE |-----------------------------------------------------------------

--------------------------------| PROCEDURE: COURT BOOKING - ADD |-------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE AddNewCourtBooking(
    p_Court_ID IN CourtBooking.Court_ID%TYPE,
    p_Day IN CourtBooking.Day%TYPE,
    p_Month IN CourtBooking.Month%TYPE,
    p_Year IN CourtBooking.Year%TYPE,
    p_Membership_ID IN CourtBooking.Membership_ID%TYPE,
    p_Timeslot IN CourtBooking.Timeslot%TYPE,
    p_Participants IN CourtBooking.Participants%TYPE,
    p_Staff_ID IN CourtBooking.Staff_ID%TYPE,
    p_Additional_Members IN VARCHAR2
)
IS
    v_Court_Booking_ID CourtBooking.Court_Booking_ID%TYPE;
BEGIN
    SELECT court_booking_sequence.NEXTVAL INTO v_Court_Booking_ID FROM DUAL;

    -- Insert into CourtBooking table
    INSERT INTO CourtBooking (Court_Booking_ID, Court_ID, Day, Month, Year, Membership_ID, Timeslot, Participants, Staff_ID)
    VALUES (v_Court_Booking_ID, p_Court_ID, p_Day, p_Month, p_Year, p_Membership_ID, p_Timeslot, p_Participants, p_Staff_ID);

    -- Additional Participants, inserted into CourtParticipants table
    IF p_Participants > 1 THEN
        FOR member IN (
            SELECT REGEXP_SUBSTR(p_Additional_Members, '[^,]+', 1, LEVEL) AS member_id
            FROM DUAL
            CONNECT BY REGEXP_SUBSTR(p_Additional_Members, '[^,]+', 1, LEVEL) IS NOT NULL
        )
        LOOP
            BEGIN
                INSERT INTO CourtParticipants (Court_Booking_ID, Membership_ID)
                VALUES (v_Court_Booking_ID, member.member_id);
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    DBMS_OUTPUT.PUT_LINE('Error: Duplicate participant for Court Booking ' || v_Court_Booking_ID || '. Skipping duplicate entry.');
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error: Failed to insert participant for Court Booking ' || v_Court_Booking_ID || '. ' || SQLERRM);
            END;
        END LOOP;
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Add Court Booking: Complete');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No data found while generating Court Booking ID.');
    WHEN OTHERS THEN
        
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

--------------------------------| PROCEDURE: COURT BOOKING - ADD - TEST DATA |-------------------------------------------------------------------
BEGIN
    AddNewCourtBooking(1, 24, 2, 2024, 1, 1500, 4, 1, '3,5,6');
    AddNewCourtBooking(2, 15, 1, 2024, 2, 1400, 2, 2, '4');
    AddNewCourtBooking(3, 5, 2, 2024, 3, 1100, 4, 3, '9,10,4');
    AddNewCourtBooking(4, 12, 1, 2024, 4, 1600, 2, 4, '5');
    AddNewCourtBooking(1, 20, 2, 2024, 5, 1500, 4, 10, '2,4,6');
    AddNewCourtBooking(2, 10, 3, 2024, 1, 1400, 2, 1, '4');
    AddNewCourtBooking(3, 6, 4, 2024, 7, 1100, 4, 2, '9,10,3');
    AddNewCourtBooking(4, 1, 2, 2024, 8, 1600, 2, 3, '5');
    AddNewCourtBooking(1, 10, 5, 2024, 9, 1600, 4, 13, '2,3,4');
    AddNewCourtBooking(2, 10, 1, 2024, 10, 1000, 2, 13, '5');
END;
/
--------------------------------| PROCEDURE: COURT - ADD/UPDATE/DELETE |-------------------------------------------------------------------------
--------------------------------| PROCEDURE: COURT BOOKING - UPDATE |----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE UpdateCourtBooking(
    p_Court_Booking_ID IN CourtBooking.Court_Booking_ID%TYPE,
    p_Court_ID IN CourtBooking.Court_ID%TYPE,
    p_Day IN CourtBooking.Day%TYPE,
    p_Month IN CourtBooking.Month%TYPE,
    p_Year IN CourtBooking.Year%TYPE,
    p_Membership_ID IN CourtBooking.Membership_ID%TYPE,
    p_Timeslot IN CourtBooking.Timeslot%TYPE,
    p_Participants IN CourtBooking.Participants%TYPE,
    p_Staff_ID IN CourtBooking.Staff_ID%TYPE,
    p_Additional_Members IN VARCHAR2
)
AS
BEGIN
    -- Update CourtBooking record
    UPDATE CourtBooking
    SET Court_ID = p_Court_ID,
        Day = p_Day,
        Month = p_Month,
        Year = p_Year,
        Membership_ID = p_Membership_ID,
        Timeslot = p_Timeslot,
        Participants = p_Participants,
        Staff_ID = p_Staff_ID
    WHERE Court_Booking_ID = p_Court_Booking_ID;
    
    DELETE FROM CourtParticipants WHERE Court_Booking_ID = p_Court_Booking_ID;
    
    -- Insert additional participants
    IF p_Additional_Members IS NOT NULL THEN
        FOR member IN (
            SELECT TRIM(REGEXP_SUBSTR(p_Additional_Members, '[^,]+', 1, LEVEL)) AS member_id
            FROM DUAL
            CONNECT BY REGEXP_SUBSTR(p_Additional_Members, '[^,]+', 1, LEVEL) IS NOT NULL
        )
        LOOP
            INSERT INTO CourtParticipants (Court_Booking_ID, Membership_ID)
            VALUES (p_Court_Booking_ID, member.member_id);
        END LOOP;
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Update Court booking: Complete');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Update Court Booking Error: ' || SQLERRM);
END;
/

--------------------------------| PROCEDURE: COURT BOOKING - UPDATE - TEST DATA |----------------------------------------------------------------
BEGIN
    UpdateCourtBooking(
        p_Court_Booking_ID => 6,
        p_Court_ID => 2,
        p_Day => 24,
        p_Month => 2,
        p_Year => 2023,
        p_Membership_ID => 5,
        p_Timeslot => 1500,
        p_Participants => 4,
        p_Staff_ID => 10,
        p_Additional_Members => '2,3,4'
    );
END;
/

--------------------------------| PROCEDURE: COURT BOOKING - DELETE |----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE DeleteCourtBooking(
    p_Court_Booking_ID IN CourtBooking.Court_Booking_ID%TYPE) AS
BEGIN
    DELETE FROM CourtParticipants WHERE Court_Booking_ID = p_Court_Booking_ID;

    DELETE FROM CourtBooking WHERE Court_Booking_ID = p_Court_Booking_ID;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Delete Court Booking ' || p_Court_Booking_ID || ': Complete');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Delete Court Booking Error: Court booking ID ' || p_Court_Booking_ID || ' not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Delete Court Booking Error: ' || SQLERRM);
END DeleteCourtBooking;
/

--------------------------------| PROCEDURE: COURT BOOKING - DELETE - TEST DATA |----------------------------------------------------------------
BEGIN
    DeleteCourtBooking(1); 
END;
/

--------------------------------| PROCEDURE: DOSAGE - ADD/UPDATE/DELETE |------------------------------------------------------------------------

--------------------------------| PROCEDURE: DOSAGE - ADD |--------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE AddDosage(
    p_Dosage IN Dosage.Dosage%TYPE,
    p_Units_Per_Day IN Dosage.Units_Per_Day%TYPE
)
IS
    v_Dosage_ID Dosage.Dosage_ID%TYPE;
BEGIN

    IF p_Units_Per_Day <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Units per day must be a positive integer.');
    END IF;

    SELECT dosage_sequence.NEXTVAL INTO v_Dosage_ID FROM DUAL;

    -- Insert the dosage record
    INSERT INTO Dosage (Dosage_ID, Dosage, Units_Per_Day)
    VALUES (v_Dosage_ID, p_Dosage, p_Units_Per_Day); 

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Add Dosage: Complete');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Add Dosage Error: No data found while fetching next sequence value.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Add Dosage Error: Duplicate dosage ID found.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Add Dosage Error: ' || SQLERRM);
END AddDosage;
/

--------------------------------| PROCEDURE: DOSAGE - ADD - TEST DATA |--------------------------------------------------------------------------
BEGIN
    AddDosage(10, 3); 
    AddDosage(15, 2);
    AddDosage(20, 4);
    AddDosage(12, 3);
    AddDosage(8, 2);
    AddDosage(25, 5);
    AddDosage(18, 4);
    AddDosage(30, 6);
    AddDosage(22, 3);
    AddDosage(16, 4);
END;
/

--------------------------------| PROCEDURE: DOSAGE - UPDATE |-----------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE UpdateDosage(
    p_Dosage_ID IN Dosage.Dosage_ID%TYPE,
    p_Dosage IN Dosage.Dosage%TYPE,
    p_Units_Per_Day IN Dosage.Units_Per_Day%TYPE
)
IS
BEGIN
    IF p_Units_Per_Day <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Units per day must be a positive number.');
    END IF;

    -- Update Dosage record
    UPDATE Dosage
    SET Dosage = p_Dosage,
        Units_Per_Day = p_Units_Per_Day
    WHERE Dosage_ID = p_Dosage_ID;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Update Dosage: Complete');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Dosage ID ' || p_Dosage_ID || ' not found.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Update Dosage Error: ' || SQLERRM);
END UpdateDosage;
/

--------------------------------| PROCEDURE: DOSAGE - UPDATE - TEST DATA |-----------------------------------------------------------------------
BEGIN
    UpdateDosage(1, 15, 5); 
END;
/

--------------------------------| PROCEDURE: DOSAGE - DELETE |-----------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE DeleteDosage(
    p_Dosage_ID IN Dosage.Dosage_ID%TYPE
)
IS
BEGIN
    DELETE FROM Dosage WHERE Dosage_ID = p_Dosage_ID;
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Delete Dosage: Complete');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        
        DBMS_OUTPUT.PUT_LINE('Delete Dosage Error: ' || SQLERRM);
END DeleteDosage;
/

--------------------------------| PROCEDURE: DOSAGE - DELETE - TEST DATA |-----------------------------------------------------------------------
BEGIN
    DeleteDosage(10); 
END;
/

--------------------------------| PROCEDURE: VITAMIN - ADD/UPDATE/DELETE |-----------------------------------------------------------------------

--------------------------------| PROCEDURE: VITAMIN - ADD |-------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE AddVitamin(
    p_Name IN Vitamin.Name%TYPE,
    p_Description IN Vitamin.Description%TYPE,
    p_Form IN Vitamin.Form%TYPE
)
IS
    v_Vitamin_ID Vitamin.Vitamin_ID%TYPE;
BEGIN
    SELECT vitamin_sequence.NEXTVAL INTO v_Vitamin_ID FROM DUAL;

    -- Insert the new Vitamin record
    INSERT INTO Vitamin (Vitamin_ID, Name, Description, Form)
    VALUES (v_Vitamin_ID, p_Name, p_Description, p_Form);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Add Vitamin: Complete');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Add Vitamin Error: No data found while generating Vitamin ID.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Add Vitamin Error: Duplicate Vitamin ID encountered.');
    WHEN OTHERS THEN
        ROLLBACK;
        
        DBMS_OUTPUT.PUT_LINE('Add Vitamin Error: ' || SQLERRM);
END AddVitamin;
/

--------------------------------| PROCEDURE: VITAMIN - ADD - TEST DATA |-------------------------------------------------------------------------
BEGIN
    AddVitamin('Vitamin B1', 'Description of Vitamin B1', 'Tablet');
    AddVitamin('Vitamin B2', 'Description of Vitamin B2', 'Capsule');
    AddVitamin('Vitamin B3', 'Description of Vitamin B3', 'Liquid');
    AddVitamin('Vitamin C', 'Description of Vitamin C', 'Tablet');
    AddVitamin('Vitamin D', 'Description of Vitamin D', 'Capsule');
    AddVitamin('Vitamin E', 'Description of Vitamin E', 'Liquid');
    AddVitamin('Vitamin K', 'Description of Vitamin K', 'Tablet');
    AddVitamin('Vitamin B6', 'Description of Vitamin B6', 'Capsule');
    AddVitamin('Vitamin B12', 'Description of Vitamin B12', 'Tablet');
    AddVitamin('Vitamin A', 'Description of Vitamin A', 'Capsule');
END;
/

--------------------------------| PROCEDURE: VITAMIN - UPDATE |----------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE UpdateVitamin(
    p_Vitamin_ID IN Vitamin.Vitamin_ID%TYPE,
    p_Name IN Vitamin.Name%TYPE,
    p_Description IN Vitamin.Description%TYPE,
    p_Form IN Vitamin.Form%TYPE
)
IS
BEGIN
    -- Update Vitamin
    UPDATE Vitamin
    SET Name = p_Name,
        Description = p_Description,
        Form = p_Form
    WHERE Vitamin_ID = p_Vitamin_ID;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Update Vitamin: Complete');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Update Vitamin Error: ' || SQLERRM);
END UpdateVitamin;
/

--------------------------------| PROCEDURE: VITAMIN - UPDATE - TEST DATA |----------------------------------------------------------------------
BEGIN
    UpdateVitamin(1, 'Super Vitamin', 'Makes you fly', 'Capsule');
END;
/

--------------------------------| PROCEDURE: VITAMIN - DELETE |----------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE DeleteVitamin(
    p_Vitamin_ID IN Vitamin.Vitamin_ID%TYPE
)
IS
BEGIN
    DELETE FROM Vitamin
    WHERE Vitamin_ID = p_Vitamin_ID;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Delete Vitamin: Complete');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Delete Vitamin Error: ' || SQLERRM);
END DeleteVitamin;
/

--------------------------------| PROCEDURE: VITAMIN - DELETE - TEST DATA |----------------------------------------------------------------------
BEGIN
    DeleteVitamin(9);
END;
/

--------------------------------| PROCEDURE: VITAMIN PLAN - ADD/UPDATE/DELETE |------------------------------------------------------------------

--------------------------------| PROCEDURE: VITAMIN PLAN - ADD |--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE AddVitaminPlan(
    p_Membership_ID IN VitaminPlan.Membership_ID%TYPE,
    p_Vitamin_ID IN VitaminPlan.Vitamin_ID%TYPE,
    p_Dosage_ID IN VitaminPlan.Dosage_ID%TYPE,
    p_Start_Day IN VitaminPlan.Start_Day%TYPE,
    p_Start_Month IN VitaminPlan.Start_Month%TYPE,
    p_Start_Year IN VitaminPlan.Start_Year%TYPE,
    p_Finish_Day IN VitaminPlan.Finish_Day%TYPE,
    p_Finish_Month IN VitaminPlan.Finish_Month%TYPE,
    p_Finish_Year IN VitaminPlan.Finish_Year%TYPE
)
IS
    v_Vitamin_Plan_ID VitaminPlan.Vitamin_Plan_ID%TYPE;
BEGIN
    SELECT vitamin_plan_sequence.NEXTVAL INTO v_Vitamin_Plan_ID FROM DUAL;

    -- Insert Vitamin Plan
    INSERT INTO VitaminPlan (Vitamin_Plan_ID, Membership_ID, Vitamin_ID, Dosage_ID, Start_Day, Start_Month, Start_Year, Finish_Day, Finish_Month, Finish_Year)
    VALUES (v_Vitamin_Plan_ID, p_Membership_ID, p_Vitamin_ID, p_Dosage_ID, p_Start_Day, p_Start_Month, p_Start_Year, p_Finish_Day, p_Finish_Month, p_Finish_Year);
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Add Vitamin Plan: Complete');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Add Vitamin Plan Error: ' || SQLERRM);
END AddVitaminPlan;
/

--------------------------------| PROCEDURE: VITAMIN PLAN - ADD - TEST DATA |--------------------------------------------------------------------
BEGIN
    AddVitaminPlan(1, 1, 1, 1, 1, 2024, 31, 12, 2024);
    AddVitaminPlan(2, 2, 2, 2, 1, 2024, 28, 2, 2024);
    AddVitaminPlan(3, 3, 3, 3, 1, 2024, 30, 4, 2024);
    AddVitaminPlan(4, 4, 4, 4, 1, 2024, 31, 5, 2024);
    AddVitaminPlan(5, 5, 5, 5, 1, 2024, 30, 6, 2024);
    AddVitaminPlan(6, 6, 6, 6, 1, 2024, 31, 7, 2024);
    AddVitaminPlan(7, 7, 7, 7, 1, 2024, 31, 8, 2024);
    AddVitaminPlan(8, 8, 8, 8, 1, 2024, 30, 9, 2024);
    AddVitaminPlan(9, 9, 9, 9, 1, 2024, 31, 10, 2024);
    AddVitaminPlan(14, 10, 10, 10, 1, 2024, 30, 11, 2024);
END;
/

--------------------------------| PROCEDURE: VITAMIN PLAN - UPDATE | ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE UpdateVitaminPlan(
    p_Vitamin_Plan_ID IN VitaminPlan.Vitamin_Plan_ID%TYPE,
    p_Membership_ID IN VitaminPlan.Membership_ID%TYPE,
    p_Vitamin_ID IN VitaminPlan.Vitamin_ID%TYPE,
    p_Dosage_ID IN VitaminPlan.Dosage_ID%TYPE,
    p_Start_Day IN VitaminPlan.Start_Day%TYPE,
    p_Start_Month IN VitaminPlan.Start_Month%TYPE,
    p_Start_Year IN VitaminPlan.Start_Year%TYPE,
    p_Finish_Day IN VitaminPlan.Finish_Day%TYPE,
    p_Finish_Month IN VitaminPlan.Finish_Month%TYPE,
    p_Finish_Year IN VitaminPlan.Finish_Year%TYPE
)
IS
BEGIN
    UPDATE VitaminPlan
    SET Membership_ID = p_Membership_ID,
        Vitamin_ID = p_Vitamin_ID,
        Dosage_ID = p_Dosage_ID,
        Start_Day = p_Start_Day,
        Start_Month = p_Start_Month,
        Start_Year = p_Start_Year,
        Finish_Day = p_Finish_Day,
        Finish_Month = p_Finish_Month,
        Finish_Year = p_Finish_Year
    WHERE Vitamin_Plan_ID = p_Vitamin_Plan_ID;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Update Vitamin Plan: Commplete.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Update Vitamin Plan Error: ' || SQLERRM);
END UpdateVitaminPlan;
/

--------------------------------| PROCEDURE: VITAMIN PLAN - UPDATE - TEST DATA |-----------------------------------------------------------------
BEGIN
    UpdateVitaminPlan(
        p_Vitamin_Plan_ID => 1,
        p_Membership_ID => 3,
        p_Vitamin_ID => 3,
        p_Dosage_ID => 3,
        p_Start_Day => 3,
        p_Start_Month => 04,
        p_Start_Year => 2023,
        p_Finish_Day => 3,
        p_Finish_Month => 05,
        p_Finish_Year => 2024 
    );
END;
/

--------------------------------| PROCEDURE: VITAMIN PLAN - DELETE |-----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE DeleteVitaminPlan(p_Vitamin_Plan_ID IN VitaminPlan.Vitamin_Plan_ID%TYPE)
IS
BEGIN
    DELETE FROM VitaminPlan WHERE Vitamin_Plan_ID = p_Vitamin_Plan_ID;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Delete Vitamin Plan: Complete');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Delete Vitamin Plan Error: ' || SQLERRM);
END DeleteVitaminPlan;
/

--------------------------------| PROCEDURE: VITAMIN PLAN - DELETE - TEST DATA |-----------------------------------------------------------------
BEGIN
    DeleteVitaminPlan(2);
END;
/
--------------------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- Queries ---------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

-- (C) List the Members -------------------------------------------------------------------------------------------------------------------------
SELECT Forenames || ' ' || Surname AS Full_Name, 
       House_Number || ' ' || Street || ', ' || Postcode AS Full_Address
FROM Membership
JOIN Address ON Membership.Address_ID = Address.Address_ID;

-------------------------------------------------------------------------------------------------------------------------------------------------
-- (D) List the details of Vitamins that are prescribed -----------------------------------------------------------------------------------------
SELECT 
    v.Name AS Vitamin_Name,
    v.Form AS Form,
    v.Description AS Description,
    d.Dosage AS Dosage,
    m.Forenames || ' ' || m.Surname AS Prescribed_To
FROM 
    VitaminPlan vp
JOIN 
    Vitamin v ON vp.Vitamin_ID = v.Vitamin_ID
JOIN 
    Dosage d ON vp.Dosage_ID = d.Dosage_ID
JOIN 
    Membership m ON vp.Membership_ID = m.Membership_ID
ORDER BY 
    Vitamin_Name, 
    Form, 
    Description, 
    Dosage, 
    Prescribed_To;

-------------------------------------------------------------------------------------------------------------------------------------------------
-- (E) List Available courts for a certain day and time -----------------------------------------------------------------------------------------
SELECT c.Court_ID, c.Court_Number
FROM Court c
WHERE NOT EXISTS (
    SELECT 1
    FROM CourtBooking cb
    WHERE cb.Court_ID = c.Court_ID
    AND cb.Day = 24
    AND cb.Month = 2
    AND cb.Year = 2024
    AND cb.Timeslot = 1500
)
ORDER BY c.Court_Number ASC;

-------------------------------------------------------------------------------------------------------------------------------------------------
-- (F) List all bookings made by a member -------------------------------------------------------------------------------------------------------
SELECT 
    cb.Court_Booking_ID,
    TO_DATE(cb.Day || '-' || cb.Month || '-' || cb.Year, 'DD-MM-YYYY') AS Booking_Date,
    TO_CHAR(TO_DATE(cb.Timeslot, 'HH24MI'), 'HH24:MI') AS Timeslot
FROM 
    CourtBooking cb
JOIN 
    Membership m ON cb.Membership_ID = m.Membership_ID
WHERE 
    m.Forenames = 'Bruce' AND m.Surname = 'Wayne';


-------------------------------------------------------------------------------------------------------------------------------------------------
-- (G) List the Vitamin dosage planner by a member ----------------------------------------------------------------------------------------------
SELECT 
    m.Forenames || ' ' || m.Surname AS Member_Name,
    v.Name AS Vitamin_Name,
    d.Dosage,
    TO_CHAR(TO_DATE(vp.Start_Day || '-' || vp.Start_Month || '-' || vp.Start_Year, 'DD-MM-YYYY'), 'DD-Mon-YYYY') AS Start_Date,
    TO_CHAR(TO_DATE(vp.Finish_Day || '-' || vp.Finish_Month || '-' || vp.Finish_Year, 'DD-MM-YYYY'), 'DD-Mon-YYYY') AS Finish_Date
FROM 
    Membership m
JOIN 
    VitaminPlan vp ON m.Membership_ID = vp.Membership_ID
JOIN 
    Vitamin v ON vp.Vitamin_ID = v.Vitamin_ID
JOIN 
    Dosage d ON vp.Dosage_ID = d.Dosage_ID
WHERE 
    m.Forenames = 'Peter' AND m.Surname = 'Parker'
ORDER BY 
    Member_Name, Vitamin_Name, Dosage, Start_Date, Finish_Date;

-------------------------------------------------------------------------------------------------------------------------------------------------
-- (H) List members who have Personalised Vitamin prescriptions but no court bookings -----------------------------------------------------------
SELECT 
    m.Forenames || ' ' || m.Surname AS Member_Name,
    vp.Vitamin_Plan_ID,
    v.Name AS Vitamin_Name,
    d.Dosage,
    TO_CHAR(TO_DATE(vp.Start_Day || '-' || vp.Start_Month || '-' || vp.Start_Year, 'DD-MM-YYYY'), 'DD-Mon-YYYY') AS Start_Date,
    TO_CHAR(TO_DATE(vp.Finish_Day || '-' || vp.Finish_Month || '-' || vp.Finish_Year, 'DD-MM-YYYY'), 'DD-Mon-YYYY') AS Finish_Date
FROM 
    Membership m
JOIN 
    VitaminPlan vp ON m.Membership_ID = vp.Membership_ID
JOIN 
    Vitamin v ON vp.Vitamin_ID = v.Vitamin_ID
JOIN 
    Dosage d ON vp.Dosage_ID = d.Dosage_ID
WHERE 
    NOT EXISTS (
        SELECT 1
        FROM CourtBooking cb 
        WHERE m.Membership_ID = cb.Membership_ID
    )
ORDER BY 
    Member_Name, vp.Vitamin_Plan_ID, Vitamin_Name, Dosage, Start_Date, Finish_Date;

-------------------------------------------------------------------------------------------------------------------------------------------------
-- (I) List members who have both Court bookings and Personalised Vitamin Dosage Planner --------------------------------------------------------
SELECT 
    m.Forenames || ' ' || m.Surname AS Member_Name,
    TO_CHAR(TO_DATE(cb.Day || '-' || cb.Month || '-' || cb.Year, 'DD-MM-YYYY'), 'DD-Mon-YYYY') AS Court_Booking_Date,
    cb.Court_ID AS Court_Number,
    TO_CHAR(TO_DATE(cb.Timeslot, 'HH24MI'), 'HH24:MI') AS Timeslot,
    cb.Participants,
    vp.Vitamin_Plan_ID,
    v.Name AS Vitamin_Name,
    d.Dosage,
    TO_CHAR(TO_DATE(vp.Start_Day || '-' || vp.Start_Month || '-' || vp.Start_Year, 'DD-MM-YYYY'), 'DD-Mon-YYYY') AS Start_Date,
    TO_CHAR(TO_DATE(vp.Finish_Day || '-' || vp.Finish_Month || '-' || vp.Finish_Year, 'DD-MM-YYYY'), 'DD-Mon-YYYY') AS Finish_Date
FROM 
    Membership m
JOIN 
    CourtBooking cb ON m.Membership_ID = cb.Membership_ID
JOIN 
    VitaminPlan vp ON m.Membership_ID = vp.Membership_ID
JOIN 
    Vitamin v ON vp.Vitamin_ID = v.Vitamin_ID
JOIN 
    Dosage d ON vp.Dosage_ID = d.Dosage_ID
WHERE 
    m.Membership_ID IN (SELECT Membership_ID FROM CourtBooking) 
    AND m.Membership_ID IN (SELECT Membership_ID FROM VitaminPlan)
ORDER BY 
    Member_Name, Court_Booking_Date, Court_Number, Timeslot, Participants, Vitamin_Plan_ID, Vitamin_Name, Dosage, Start_Date, Finish_Date;

-------------------------------------------------------------------------------------------------------------------------------------------------
-- (J) List Members who are below 18 years of age -----------------------------------------------------------------------------------------------
SELECT 
    m.Forenames || ' ' || m.Surname AS Full_Name,
    m.Age,
    a.House_Number || ' ' || a.Street || ', ' || a.Postcode AS Address
FROM 
    Membership m
JOIN 
    Address a ON m.Address_ID = a.Address_ID
WHERE 
    m.Age < 18
ORDER BY 
    Full_Name, Age, Address;

-------------------------------------------------------------------------------------------------------------------------------------------------
-- (K) List court bookings during a certain period (01/01/2024 - 29/02/2024) --------------------------------------------------------------------
WITH formatted_dates AS (
    SELECT TO_DATE('01-01-2024', 'DD-MM-YYYY') AS start_date, TO_DATE('29-02-2024', 'DD-MM-YYYY') AS end_date
    FROM dual
)
SELECT 
    cb.Court_Booking_ID,
    c.Court_Number,
    LPAD(FLOOR(cb.Timeslot / 100), 2, '0') || ':' || LPAD(MOD(cb.Timeslot, 100), 2, '0') AS Timeslot,
    TO_CHAR(TO_DATE(cb.Day || '-' || cb.Month || '-' || cb.Year, 'DD-MM-YYYY'), 'DD/MM/YYYY') AS Court_Booking_Date,
    m.Forenames || ' ' || m.Surname AS Membership_Name,
    LISTAGG(m2.Forenames || ' ' || m2.Surname, ', ') WITHIN GROUP (ORDER BY m2.Forenames, m2.Surname) AS Participant_Names
FROM 
    CourtBooking cb
JOIN 
    Court c ON cb.Court_ID = c.Court_ID
JOIN 
    Membership m ON cb.Membership_ID = m.Membership_ID
LEFT JOIN 
    CourtParticipants cp ON cb.Court_Booking_ID = cp.Court_Booking_ID
LEFT JOIN
    Membership m2 ON cp.Membership_ID = m2.Membership_ID
CROSS JOIN
    formatted_dates fd
WHERE 
    TO_DATE(cb.Day || '-' || cb.Month || '-' || cb.Year, 'DD-MM-YYYY') BETWEEN fd.start_date AND fd.end_date
GROUP BY 
    cb.Court_Booking_ID, c.Court_Number, cb.Timeslot, cb.Day, cb.Month, cb.Year, m.Forenames, m.Surname
ORDER BY 
    TO_DATE(cb.Day || '-' || cb.Month || '-' || cb.Year, 'DD-MM-YYYY'), cb.Timeslot, m.Forenames, m.Surname;

-------------------------------------------------------------------------------------------------------------------------------------------------
-- (L) List a joint display the Vitamins prescribed and the court bookings for a particular member. ---------------------------------------------
SELECT 
    m.Forenames || ' ' || m.Surname AS Member_Name,
    TO_DATE(cb.Day || '-' || cb.Month || '-' || cb.Year, 'DD-MM-YYYY') AS Court_Booking_Date,
    cb.Court_ID AS Court_Number,
    LPAD(FLOOR(cb.Timeslot / 100), 2, '0') || ':' || LPAD(MOD(cb.Timeslot, 100), 2, '0') AS Timeslot,
    cb.Participants,
    vp.Vitamin_Plan_ID,
    v.Name AS Vitamin_Name,
    d.Dosage,
    TO_DATE(vp.Start_Day || '-' || vp.Start_Month || '-' || vp.Start_Year, 'DD-MM-YYYY') AS Start_Date,
    TO_DATE(vp.Finish_Day || '-' || vp.Finish_Month || '-' || vp.Finish_Year, 'DD-MM-YYYY') AS Finish_Date
FROM 
    Membership m
JOIN 
    CourtBooking cb ON m.Membership_ID = cb.Membership_ID
JOIN 
    VitaminPlan vp ON m.Membership_ID = vp.Membership_ID
JOIN 
    Vitamin v ON vp.Vitamin_ID = v.Vitamin_ID
JOIN 
    Dosage d ON vp.Dosage_ID = d.Dosage_ID
WHERE 
    m.Forenames = 'Bruce' AND m.Surname = 'Wayne'
ORDER BY 
    Member_Name, Court_Booking_Date, Court_Number, Timeslot, Participants, Vitamin_Plan_ID, Vitamin_Name, Dosage, Start_Date, Finish_Date;

-------------------------------------------------------------------------------------------------------------------------------------------------