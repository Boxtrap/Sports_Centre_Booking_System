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
