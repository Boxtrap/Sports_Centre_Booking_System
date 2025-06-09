-- List members who have Personalised Vitamin prescriptions but no court bookings -----------------------------------------------------------
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
