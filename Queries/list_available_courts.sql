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
