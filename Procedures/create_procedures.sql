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
