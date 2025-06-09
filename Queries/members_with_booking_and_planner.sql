-- List members who have both Court bookings and Personalised Vitamin Dosage Planner --------------------------------------------------------
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
