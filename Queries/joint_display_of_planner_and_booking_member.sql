-- List a joint display the Vitamins prescribed and the court bookings for a particular member. ---------------------------------------------
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
