USE master;
GO

CREATE DATABASE GivingVeinDW;
GO

USE GivingVeinDW;
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE Dim_Donors (
    donor_key INT NOT NULL IDENTITY (1,1)
        CONSTRAINT PK_Dim_Donors PRIMARY KEY,
    donor_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    middle_initial CHAR(1) NULL,
    age INT NOT NULL,
    gender VARCHAR(10) NOT NULL,
    email VARCHAR(100) NULL,
    address VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip VARCHAR(10) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    exercises VARCHAR(3) NULL,
    sexually_active VARCHAR(3) NULL,
    height_inches INT NULL
);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Dim_Provider (
    provider_key INT NOT NULL IDENTITY(1,1)
        CONSTRAINT PK_Dim_Provider PRIMARY KEY,
    provider_id INT NOT NULL,
    provider_type VARCHAR(50) NULL,
    provider_first_name VARCHAR(50) NULL,
    provider_last_name VARCHAR(50) NULL
);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Dim_Blood_Type (
    blood_type_key INT NOT NULL IDENTITY(1,1)
        CONSTRAINT PK_Dim_Blood_type PRIMARY KEY,
    blood_type_id INT NOT NULL,
    blood_type_desc VARCHAR(50) NOT NULL,
    rh_type VARCHAR(10) NOT NULL
);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Dim_Donation_Locations (
    location_key INT NOT NULL IDENTITY(1,1)
        CONSTRAINT PK_Dim_Donation_Locations PRIMARY KEY,
    location_id INT,
    location_name VARCHAR(100),
    location_contact_name VARCHAR(50),
    location_contact_title VARCHAR(50),
    location_address VARCHAR(100),
    location_city VARCHAR(50),
    location_state VARCHAR(50),
    location_zip VARCHAR(10)
);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

   CREATE TABLE Dim_Date (
        DateKey DATETIME
            CONSTRAINT PK_Dim_Date PRIMARY KEY,
        FullDate DATE,
        Year INT,
        Month INT,
        Day INT,
        Weekday INT,
        WeekdayName VARCHAR(20),
        MonthName VARCHAR(20),
        Quarter INT,
        IsLeapYear BIT
    )

--------------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE TABLE Fact_Donations(
    donor_key INT NOT NULL,
    blood_type_key INT NOT NULL,
    provider_key INT NOT NULL,
    location_key INT NOT NULL,
    donation_date_key DATETIME NOT NULL,
    appointment_datetime_key DATETIME NOT NULL,
    appointment_canceled VARCHAR(3) NULL,
    donation_amount DECIMAL(10, 2) NULL,
    donation_type VARCHAR(50) NULL,
        CONSTRAINT PK_Fact_Donations PRIMARY KEY (donor_key, blood_type_key, provider_key, location_key, donation_date_key, appointment_datetime_key),

        CONSTRAINT [FK_Dim_Blood_Type] FOREIGN KEY([blood_type_key])
            REFERENCES [dbo].[Dim_Blood_Type] ([blood_type_key]),
       CONSTRAINT [FK_Dim_Donation_AppointmentDate] FOREIGN KEY([appointment_datetime_key])
            REFERENCES [dbo].[Dim_Date] ([DateKey]),
       CONSTRAINT [FK_Dim_Donation_Date] FOREIGN KEY([donation_date_key])
            REFERENCES [dbo].[Dim_Date] ([DateKey]),
       CONSTRAINT [FK_Dim_Donor] FOREIGN KEY([donor_key])
            REFERENCES [dbo].[Dim_Donors] ([donor_key]),
       CONSTRAINT [FK_Dim_Location] FOREIGN KEY([location_key])
            REFERENCES [dbo].[Dim_Donation_Locations] ([location_key]),
       CONSTRAINT [FK_Dim_Primary_Provider] FOREIGN KEY([provider_key])
            REFERENCES [dbo].[Dim_Provider] ([provider_key])

    
);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Dim_LabLocations (
    lab_key INT NOT NULL IDENTITY(1,1)
        CONSTRAINT PK_Dim_LabLocations PRIMARY KEY,
    lab_id INT NOT NULL,
	lab_name VARCHAR(50) NOT NULL,
	lab_contact_name VARCHAR(50) NULL,
	lab_contact_title VARCHAR(50) NULL,
	lab_address VARCHAR(50) NOT NULL,
	lab_city VARCHAR(50) NOT NULL,
	lab_state VARCHAR(2) NOT NULL,
	lab_zip VARCHAR(5) NOT NULL,
)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Dim_Tests (
    test_key INT NOT NULL IDENTITY(1,1)
        CONSTRAINT PK_Dim_Tests PRIMARY KEY,
    test_id INT NOT NULL,
    test_desc VARCHAR(100) NOT NULL,
    test_price SMALLMONEY NOT NULL
)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Fact_LabOrderTotals (
    order_key INT NOT NULL,
    donor_key INT NOT NULL,
    lab_key INT NOT NULL,
    order_date_key DATETIME NOT NULL,
    ship_date_key DATETIME NOT NULL,
    total_tests INT NOT NULL,
    freight SMALLMONEY NOT NULL,
    order_total MONEY NOT NULL,
    order_total_freight MONEY NOT NULL
        CONSTRAINT PK_Fact_LabOrderTotals PRIMARY KEY(donor_key, lab_key, order_date_key, ship_date_key),
        CONSTRAINT FK_Dim_Donor_LabOrderTotals FOREIGN KEY(donor_key)
            REFERENCES Dim_Donors(donor_key),
        CONSTRAINT FK_Dim_LabLocation FOREIGN KEY(lab_key)
            REFERENCES Dim_LabLocations(lab_key),
        CONSTRAINT FK_Dim_Date_OrderDate FOREIGN KEY(order_date_key)
            REFERENCES Dim_Date(DateKey),
        CONSTRAINT FK_Dim_Date_ShipDate FOREIGN KEY(ship_date_key)
            REFERENCES Dim_Date(DateKey),
		CONSTRAINT UNQ_LabOrderTotals UNIQUE(order_key)
)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE Fact_OrderTransactions (
    order_key INT NOT NULL,
    test_key INT NOT NULL,
    donor_key INT NOT NULL,
    lab_key INT NOT NULL,
    test_date_key DATETIME NOT NULL,
    test_price SMALLMONEY NOT NULL,
    test_results VARCHAR(100) NOT NULL
        CONSTRAINT PK_Fact_OrderTransactions PRIMARY KEY(order_key, test_key, lab_key, test_date_key),
        CONSTRAINT FK_Dim_Tests FOREIGN KEY(test_key)
            REFERENCES Dim_Tests(test_key),
        CONSTRAINT FK_Dim_LabLocation_OrderTransactions FOREIGN KEY(lab_key)
            REFERENCES Dim_LabLocations(lab_key),
        CONSTRAINT FK_Dim_Date_OrderTransactions FOREIGN KEY(test_date_key)
            REFERENCES Dim_Date(DateKey),
		CONSTRAINT FK_Fact_LabOrderTotals FOREIGN KEY(order_key)
			REFERENCES Fact_LabOrderTotals(order_key),
        CONSTRAINT FK_Dim_Donor_OrderTransactions FOREIGN KEY(donor_key)
            REFERENCES Dim_Donors(donor_key)
)


