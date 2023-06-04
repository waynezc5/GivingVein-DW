USE GivingVeinDW;
GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE spLoad_DimDonors
AS
BEGIN
    MERGE INTO Dim_Donors AS T
    USING (
        SELECT 
            D.donor_id,
            D.first_name,
            D.last_name,
            D.middle_initial,
            D.age,
            D.gender,
            D.email,
            A.address,
            A.city,
            A.state,
            A.zip,
            P.phone_number,
            CASE
                WHEN MH.exercise_ind = 0 THEN 'No'
                ELSE 'Yes'
            END AS exercises,
            CASE
                WHEN MH.sexually_active_ind = 0 THEN 'No'
                ELSE 'Yes'
            END AS sexually_active,
            MH.height_inches
        FROM GivingVein.Donors.Donor AS D
        INNER JOIN GivingVein.Donors.Address AS A
            ON D.address_id = A.address_id
        INNER JOIN GivingVein.Donors.Phone AS P
            ON D.phone_id = P.phone_id
        INNER JOIN GivingVein.Donors.Medical_History AS MH
            ON D.medical_history_id = MH.medical_history_id
    ) AS S
    ON (T.donor_id = S.donor_id)
    WHEN MATCHED THEN
        UPDATE SET
            first_name = S.first_name,
            last_name = S.last_name,
            middle_initial = S.middle_initial,
            age = S.age,
            gender = S.gender,
            email = S.email,
            address = S.address,
            city = S.city,
            state = S.state,
            zip = S.zip,
            phone_number = S.phone_number,
            exercises = S.exercises,
            sexually_active = S.sexually_active,
            height_inches = S.height_inches
    WHEN NOT MATCHED THEN
        INSERT (
            donor_id,
            first_name,
            last_name,
            middle_initial,
            age,
            gender,
            email,
            address,
            city,
            state,
            zip,
            phone_number,
            exercises,
            sexually_active,
            height_inches
        )
        VALUES (
            S.donor_id,
            S.first_name,
            S.last_name,
            S.middle_initial,
            S.age,
            S.gender,
            S.email,
            S.address,
            S.city,
            S.state,
            S.zip,
            S.phone_number,
            S.exercises,
            S.sexually_active,
            S.height_inches
        );
END;

GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE spLoad_DimDate
AS
BEGIN;

  -- Load data into the date dimension table
    DECLARE @StartDate DATE = '2015-01-01'
    DECLARE @EndDate DATE = '2025-12-31'

    WHILE @StartDate <= @EndDate
    BEGIN
        INSERT INTO Dim_Date (DateKey, FullDate, Year, Month, Day, Weekday, WeekdayName, MonthName, Quarter, IsLeapYear)
        VALUES (
            @StartDate,
            @StartDate,
            YEAR(@StartDate),
            MONTH(@StartDate),
            DAY(@StartDate),
            DATEPART(WEEKDAY, @StartDate),
            DATENAME(WEEKDAY, @StartDate),
            DATENAME(MONTH, @StartDate),
            DATEPART(QUARTER, @StartDate),
            CASE WHEN YEAR(@StartDate) % 4 = 0 AND (YEAR(@StartDate) % 100 != 0 OR YEAR(@StartDate) % 400 = 0) THEN 1 ELSE 0 END
        )

        SET @StartDate = DATEADD(DAY, 1, @StartDate)
    END
END;

GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE spLoad_DimProvider
AS
BEGIN
    MERGE INTO Dim_Provider AS T
    USING (
        SELECT 
            HP.provider_id,
            PT.provider_type,
            HP.provider_first_name,
            HP.provider_last_name
        FROM GivingVein.Donors.Healthcare_Provider AS HP
        INNER JOIN GivingVein.Donors.Provider_Type AS PT
            ON HP.provider_type_id = PT.provider_type_id
    ) AS S
    ON (T.provider_id = S.provider_id)
    WHEN MATCHED THEN
        UPDATE SET
            provider_type = S.provider_type,
            provider_first_name = S.provider_first_name,
            provider_last_name = S.provider_last_name
    WHEN NOT MATCHED THEN
        INSERT (
            provider_id,
            provider_type,
            provider_first_name,
            provider_last_name
        )
        VALUES (
            S.provider_id,
            S.provider_type,
            S.provider_first_name,
            S.provider_last_name
        );
END;

GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE spLoad_DimBloodType
AS
BEGIN

    MERGE INTO Dim_Blood_Type AS T
    USING (
        SELECT
            blood_type_id,
            blood_type_desc,
            rh_type
        FROM GivingVein.Donors.Blood_Type
    ) AS S
    ON (T.blood_type_id = S.blood_type_id)
    WHEN MATCHED THEN
        UPDATE SET
            blood_type_desc = S.blood_type_desc,
			rh_type = S.rh_type
    WHEN NOT MATCHED THEN
        INSERT (
            blood_type_id,
            blood_type_desc,
            rh_type
        )
        VALUES (
            S.blood_type_id,
            S.blood_type_desc,
            S.rh_type
        );
END;

GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE spLoad_DimDonationLocations
AS
BEGIN
    MERGE INTO Dim_Donation_Locations AS T
    USING (
        SELECT 
            location_id,
            location_name,
            location_contact_name,
            location_contact_title,
            location_address,
            location_city,
            location_state,
            location_zip
        FROM GivingVein.Donors.Location
    ) AS S
    ON (T.location_id = S.location_id)
    WHEN MATCHED THEN
        UPDATE SET
            location_name = S.location_name,
            location_contact_name = S.location_contact_name,
            location_contact_title = S.location_contact_title,
            location_address = S.location_address,
            location_city = S.location_city,
            location_state = S.location_state,
            location_zip = S.location_zip
    WHEN NOT MATCHED THEN
        INSERT (
            location_id,
            location_name,
            location_contact_name,
            location_contact_title,
            location_address,
            location_city,
            location_state,
            location_zip
        )
        VALUES (
            S.location_id,
            S.location_name,
            S.location_contact_name,
            S.location_contact_title,
            S.location_address,
            S.location_city,
            S.location_state,
            S.location_zip
        );
END;

GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE spLoad_FactDonations
AS
BEGIN;

    MERGE Fact_Donations AS F
    USING (
        SELECT
            DSK.donor_key AS donor_key,
            BSK.blood_type_key AS blood_type_key,
            PSK.provider_key AS provider_key,
            LSK.location_key AS location_key,
            donation_date,
            DA.appointment_datetime,
            CASE
                WHEN DA.appointment_cancelation_ind = 0 THEN 'No'
                ELSE 'Yes'
            END AS appointment_canceled,
            donation_amount,
            donation_type
        FROM [GivingVein].[Donors].[Donation] AS DO
            INNER JOIN GivingVein.Donors.Donor AS D
                ON DO.donor_id = D.donor_id
            INNER JOIN Dim_Donors AS DSK
                ON DSK.donor_id = D.donor_id
            INNER JOIN Dim_Blood_Type AS BSK
                ON BSK.blood_type_id = D.blood_type_id
            INNER JOIN Dim_Provider AS PSK
                ON PSK.provider_id = D.primary_provider_id
            INNER JOIN Dim_Donation_Locations AS LSK
                ON LSK.location_id = DO.location_id
            INNER JOIN [GivingVein].[Donors].[Appointments] AS DA
                ON DO.appointment_id = DA.appointment_id
            
    ) AS S
    ON F.donor_key = S.donor_key
        AND F.blood_type_key = S.blood_type_key
        AND F.provider_key = S.provider_key
        AND F.location_key = S.location_key
        AND F.donation_date_key = S.donation_date
        AND F.appointment_datetime_key = S.appointment_datetime
        AND F.appointment_canceled = S.appointment_canceled
        AND F.donation_amount = S.donation_amount
        AND F.donation_type = S.donation_type
    WHEN NOT MATCHED THEN
        INSERT (
            [donor_key],
            [blood_type_key],
            [provider_key],
            [location_key],
            [donation_date_key],
            [appointment_datetime_key],
            [appointment_canceled],
            [donation_amount],
            [donation_type]
        )
    VALUES (
        S.[donor_key],
        S.[blood_type_key],
        S.[provider_key],
        S.[location_key],
        S.[donation_date],
        S.[appointment_datetime],
        S.[appointment_canceled],
        S.[donation_amount],
        S.[donation_type]
    );
END;

GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE spLoad_DimLabLocations
AS
BEGIN;

    MERGE INTO Dim_LabLocations AS T
    USING (
        SELECT lab_id,
            lab_name,
            lab_contact_name,
            lab_contact_title,
            lab_address,
            lab_city,
            lab_state,
            lab_zip
        FROM GivingVein.Lab.Location
    ) AS S
    ON (T.lab_id = S.lab_id)
    WHEN MATCHED THEN
        UPDATE SET
            lab_name = S.lab_name,
            lab_contact_name = S.lab_contact_name,
            lab_contact_title = S.lab_contact_title,
            lab_address = S.lab_address,
            lab_city = S.lab_city,
            lab_state = S.lab_state,
            lab_zip = S.lab_zip
    WHEN NOT MATCHED THEN
        INSERT (
            lab_id,
            lab_name,
            lab_contact_name,
            lab_contact_title,
            lab_address,
            lab_city,
            lab_state,
            lab_zip
        )
        VALUES (
            S.lab_id,
            S.lab_name,
            S.lab_contact_name,
            S.lab_contact_title,
            S.lab_address,
            S.lab_city,
            S.lab_state,
            S.lab_zip
        );
END;
GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE spLoad_DimTests
AS
BEGIN;
    MERGE INTO Dim_Tests AS T
    USING (
        SELECT test_id,
            test_desc,
            test_price
        FROM GivingVein.Lab.Tests
    ) AS S
    ON (T.test_key = S.test_id)
    WHEN MATCHED THEN
        UPDATE SET
            test_desc = S.test_desc,
            test_price = S.test_price
    WHEN NOT MATCHED THEN
        INSERT (
            test_id,
            test_desc,
            test_price
        )
        VALUES (
            S.test_id,
            S.test_desc,
            S.test_price
        );
END;

GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE spLoad_FactLabOrderTotals
AS
BEGIN;

    MERGE Fact_LabOrderTotals AS F
    USING (
        SELECT 
            O.order_id,
            DSK.donor_key AS donor_key,
            LSK.lab_key AS lab_key,
            O.order_date,
            O.ship_date,
            COUNT(OD.test_id) AS total_tests,
            O.freight,
            SUM(OD.test_price) AS [order_total],
	        (SUM(OD.test_price) + O.freight) AS [order_total_freight]
        FROM GivingVein.Lab.Orders AS O
            INNER JOIN GivingVein.Lab.Order_Details AS OD
                ON O.order_id = OD.order_id
            INNER JOIN GivingVein.Lab.Tests AS T
                ON OD.test_id = T.test_id
            INNER JOIN GivingVein.Donors.Donor AS D
                ON O.donor_id = D.donor_id
            INNER JOIN Dim_Donors AS DSK
                ON DSK.donor_id = D.donor_id
            INNER JOIN Dim_LabLocations AS LSK
                ON LSK.lab_id = O.lab_id
        GROUP BY
            O.order_id,
            DSK.donor_key,
            LSK.lab_key,
            O.order_date,
            O.ship_date,
            O.freight
        ) AS S
        ON F.order_key = S.order_id
            AND F.donor_key = S.donor_key
            AND F.lab_key = S.lab_key
            AND F.order_date_key = S.order_date
            AND F.ship_date_key = S.ship_date
            AND F.total_tests = S.total_tests
            AND F.freight = S.freight
            AND F.order_total = S.order_total
            AND F.order_total_freight = S.order_total_freight
        WHEN NOT MATCHED THEN
            INSERT (
                order_key,
                donor_key,
                lab_key,
                order_date_key,
                ship_date_key,
                total_tests,
                freight,
                order_total,
                order_total_freight
            )
            VALUES (
                S.order_id,
                S.donor_key,
                S.lab_key,
                S.order_date,
                S.ship_date,
                S.total_tests,
                S.freight,
                S.order_total,
                S.order_total_freight
            );
END;

GO

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE spLoad_FactOrderTransactions
AS
BEGIN;

    MERGE Fact_OrderTransactions AS F
    USING (
        SELECT 
            OSK.order_key AS order_key,
            TSK.test_key AS test_key,
            DSK.donor_key AS donor_key,
            LSK.lab_key AS lab_key,
            OD.test_date,
            OD.test_price,
            OD.test_results
        FROM GivingVein.Lab.Order_Details AS OD
            INNER JOIN GivingVein.Lab.Orders AS O
                ON OD.order_id = O.order_id
            INNER JOIN GivingVein.Lab.Tests AS T
                ON OD.test_id = T.test_id
            INNER JOIN GivingVein.Donors.Donor AS D
                ON O.donor_id = D.donor_id
            INNER JOIN GivingVein.Lab.Location AS L
                ON O.lab_id = L.lab_id
            INNER JOIN Dim_Donors AS DSK
                ON DSK.donor_key = D.donor_id
            INNER JOIN Dim_Tests AS TSK
                ON TSK.test_key = T.test_id
            INNER JOIN Dim_LabLocations AS LSK
                ON LSK.lab_key = L.lab_id
            INNER JOIN Fact_LabOrderTotals AS OSK
                ON OSK.order_key = O.order_id
    ) AS S
    ON F.order_key = S.order_key
        AND F.test_key = S.test_key
        AND F.donor_key = S.donor_key
        AND F.lab_key = S.lab_key
        AND F.test_date_key = S.test_date
        AND F.test_price = S.test_price
        AND F.test_results = S.test_results
    WHEN NOT MATCHED THEN
        INSERT (
            order_key,
            test_key,
            donor_key,
            lab_key,
            test_date_key,
            test_price,
            test_results
        )
    VALUES (
        S.order_key,
        S.test_key,
		S.donor_key,
        S.lab_key,
        S.test_date,
        S.test_price,
        S.test_results
    );

END;

GO
