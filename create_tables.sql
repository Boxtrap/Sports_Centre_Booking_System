-------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------- CREATE TABLE ----------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------

-- CREATE TABLE: ADDRESS ------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Address (
    Address_ID NUMBER PRIMARY KEY,
    House_Number NUMBER,
    Street VARCHAR2(100),
    Postcode VARCHAR2(20)
);

-- CREATE TABLE: MEMBERSHIP ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE Membership (
    Membership_ID NUMBER PRIMARY KEY,
    Surname VARCHAR2(30),
    Forenames VARCHAR2(30),
    Age NUMBER,
    Address_ID NUMBER,
    FOREIGN KEY (Address_ID) REFERENCES Address (Address_ID)
);

-- CREATE TABLE: COURT --------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Court (
    Court_ID NUMBER PRIMARY KEY,
    Court_Number NUMBER
);

-- CREATE TABLE: STAFF --------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Staff (
    Staff_ID NUMBER PRIMARY KEY,
    Surname VARCHAR2(50),
    Forename VARCHAR2(50),
    Job_Role VARCHAR2(50),
    Address_ID NUMBER,
    FOREIGN KEY (Address_ID) REFERENCES Address(Address_ID)
);

-- CREATE TABLE: COURT BOOKING -------------------------------------------------------------------------------------------------------------------
CREATE TABLE CourtBooking (
    Court_Booking_ID NUMBER PRIMARY KEY,
    Court_ID NUMBER,
    Day NUMBER,
    Month NUMBER,
    Year NUMBER,
    Membership_ID NUMBER,
    Timeslot NUMBER,
    Participants NUMBER,
    Staff_ID NUMBER,
    FOREIGN KEY (Membership_ID) REFERENCES Membership(Membership_ID),
    FOREIGN KEY (Court_ID) REFERENCES Court(Court_ID),
    FOREIGN KEY (Staff_ID) REFERENCES Staff(Staff_ID)
);

-- CREATE TABLE: COURT PARTICIPANTS ---------------------------------------------------------------------------------------------------------------
CREATE TABLE CourtParticipants (
    Court_Booking_ID NUMBER,
    Membership_ID NUMBER,
    PRIMARY KEY (Court_Booking_ID, Membership_ID),
    FOREIGN KEY (Court_Booking_ID) REFERENCES CourtBooking(Court_Booking_ID),
    FOREIGN KEY (Membership_ID) REFERENCES Membership(Membership_ID)
);

-- CREATE TABLE: DOSAGE ---------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Dosage (
    Dosage_ID NUMBER PRIMARY KEY,
    Dosage NUMBER,
    Units_Per_Day NUMBER
);

-- CREATE TABLE: VITAMIN --------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Vitamin (
    Vitamin_ID NUMBER PRIMARY KEY,
    Name VARCHAR2(50),
    Description VARCHAR2(250),
    Form VARCHAR2(20)
);

-- CREATE TABLE: VITAMIN PLAN ---------------------------------------------------------------------------------------------------------------------
CREATE TABLE VitaminPlan (
    Vitamin_Plan_ID NUMBER PRIMARY KEY,
    Membership_ID NUMBER,
    Vitamin_ID NUMBER,
    Dosage_ID NUMBER,
    Start_Day NUMBER,
    Start_Month NUMBER,
    Start_Year NUMBER,
    Finish_Day NUMBER,
    Finish_Month NUMBER,
    Finish_Year NUMBER,
    FOREIGN KEY (Membership_ID) REFERENCES Membership(Membership_ID),
    FOREIGN KEY (Vitamin_ID) REFERENCES Vitamin(Vitamin_ID),
    FOREIGN KEY (Dosage_ID) REFERENCES Dosage(Dosage_ID)
);
