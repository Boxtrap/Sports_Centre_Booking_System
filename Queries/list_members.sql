-- List the Members -------------------------------------------------------------------------------------------------------------------------
SELECT Forenames || ' ' || Surname AS Full_Name, 
       House_Number || ' ' || Street || ', ' || Postcode AS Full_Address
FROM Membership
JOIN Address ON Membership.Address_ID = Address.Address_ID;

--------------------------------------------------------------
