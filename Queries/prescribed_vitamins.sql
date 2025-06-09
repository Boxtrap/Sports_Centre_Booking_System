-- List the details of Vitamins that are prescribed -----------------------------------------------------------------------------------------
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
