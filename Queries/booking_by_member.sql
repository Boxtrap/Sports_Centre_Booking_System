-- List all bookings made by a member -------------------------------------------------------------------------------------------------------
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
