-- List Members who are below 18 years of age -----------------------------------------------------------------------------------------------
SELECT 
    m.Forenames || ' ' || m.Surname AS Full_Name,
    m.Age,
    a.House_Number || ' ' || a.Street || ', ' || a.Postcode AS Address
FROM 
    Membership m
JOIN 
    Address a ON m.Address_ID = a.Address_ID
WHERE 
    m.Age < 18
ORDER BY 
    Full_Name, Age, Address;
