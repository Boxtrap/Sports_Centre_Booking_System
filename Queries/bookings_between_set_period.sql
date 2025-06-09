-- List court bookings during a certain period (01/01/2024 - 29/02/2024) --------------------------------------------------------------------
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
