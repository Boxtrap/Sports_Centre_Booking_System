-- List the Vitamin dosage planner by a member ----------------------------------------------------------------------------------------------
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
