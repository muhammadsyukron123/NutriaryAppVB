-----------------------------------------
-- 1. usp_RegisterUser STORE PROCEDURE --
-----------------------------------------

CREATE OR ALTER PROCEDURE usp_RegisterUser
    @username NVARCHAR(50),
    @email NVARCHAR(100),
    @password NVARCHAR(100)
AS
BEGIN
    DECLARE @hashed_password NVARCHAR(100);

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Periksa apakah username sudah ada
        IF EXISTS (SELECT 1 FROM Users WHERE username = @username)
        BEGIN
            THROW 51000, 'Username already exists.', 1;
        END

        -- Periksa apakah email sudah ada
        IF EXISTS (SELECT 1 FROM Users WHERE email = @email)
        BEGIN
            THROW 51001, 'Email already exists.', 1;
        END

        -- Hash password
        SET @hashed_password = HASHBYTES('SHA2_256', @password);

        -- Insert ke tabel Users
        INSERT INTO Users (username, email, password)
        VALUES (@username, @email, @hashed_password)

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Tangani error di sini
        THROW;
    END CATCH
END



-- Menjalankan stored procedure RegisterUser dengan parameter yang sesuai
EXEC usp_RegisterUser 
    @username = 'john_doe2',
    @email = 'john2@example.com',
    @password = 'password123' 

----------------------------------------------
-- 2. usp_insertUserProfile Store Procedure --
----------------------------------------------

CREATE OR ALTER PROCEDURE usp_InsertUserProfile
    @user_id INT,
    @gender NVARCHAR(10),
    @age INT,
    @height DECIMAL(5, 2),
    @weight DECIMAL(5, 2),
    @activity_level_id INT,
    @target_goal_id INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Cek apakah sudah ada UserProfile untuk user_id tertentu
        IF EXISTS (SELECT 1 FROM UserProfile WHERE user_id = @user_id)
        BEGIN
            -- Jika sudah ada, lakukan update
            UPDATE UserProfile
            SET gender = @gender,
                age = @age,
                height = @height,
                weight = @weight
            WHERE user_id = @user_id;

			UPDATE UserCalorieInformation
			SET user_id = @user_id,
				activity_level_id = @activity_level_id,
				target_goal_id = @target_goal_id
        END
        ELSE
        BEGIN
            -- Jika belum ada, lakukan insert baru
            INSERT INTO UserProfile (user_id, gender, age, height, weight)
            VALUES (@user_id, @gender, @age, @height, @weight);

			-- Insert ke tabel UserCalorieInformation
			-- Lakukan operasi ini tanpa pengecekan karena bisa saja data belum ada dan perlu dimasukkan baru
			INSERT INTO UserCalorieInformation (user_id, activity_level_id, target_goal_id)
			VALUES (@user_id, @activity_level_id, @target_goal_id);

        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Tangani error di sini
        THROW;
    END CATCH
END


EXEC usp_InsertUserProfile 
	@user_id = 10,
	@gender = 'Male',
    @age = 30,
    @height = 180,
    @weight = 75.0,
    @activity_level_id = 1, -- Misalnya, tingkat aktivitas sedang
    @target_goal_id = 1 -- Misalnya, tujuan diet untuk menjaga berat badan

SELECT*FROM UserProfile
SELECT*FROM UserCalorieInformation

--------------------------------------
-- 3. usp_LoginUser Store Procedure --
--------------------------------------

CREATE OR ALTER PROCEDURE usp_LoginUser
    @username NVARCHAR(50),
    @password NVARCHAR(100),
    @loginResult INT OUTPUT -- Add an output parameter to return the login result
AS
BEGIN
    DECLARE @user_id INT;
    DECLARE @stored_password NVARCHAR(100);
    DECLARE @hashed_password NVARCHAR(100);

    BEGIN TRANSACTION;

    BEGIN TRY
        -- Mengambil user_id dan password yang di-hash dari tabel Users berdasarkan username
        SELECT @user_id = user_id, @stored_password = password
        FROM Users
        WHERE username = @username;

        -- Memeriksa apakah username ditemukan
        IF (@user_id IS NOT NULL)
        BEGIN
            -- Hash password yang dimasukkan pada saat login
            SET @hashed_password = HASHBYTES('SHA2_256', @password);

            -- Memeriksa apakah password cocok
            IF (@hashed_password = @stored_password)
            BEGIN
                -- Berhasil masuk, set nilai hasil login ke 1
                SET @loginResult = 1;
                -- Tidak perlu melakukan apa-apa selain melakukan COMMIT
                COMMIT TRANSACTION;
                PRINT 'Login berhasil.';
            END
            ELSE
            BEGIN
                -- Password tidak cocok, set nilai hasil login ke 0
                SET @loginResult = 0;
                -- Password tidak cocok, mengembalikan pesan kesalahan
                THROW 51000, 'Password salah.', 1;
            END
        END
        ELSE
        BEGIN
            -- Username tidak ditemukan, set nilai hasil login ke 0
            SET @loginResult = 0;
            -- Username tidak ditemukan, mengembalikan pesan kesalahan
            THROW 51000, 'Username tidak ditemukan.', 1;
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Menampilkan pesan kesalahan
        PRINT ERROR_MESSAGE();
    END CATCH
END



-- Menjalankan stored procedure LoginUser dengan parameter yang sesuai
DECLARE @username NVARCHAR(50) = 'john_doe2';
DECLARE @password NVARCHAR(100) = 'password123';
DECLARE @loginResult INT;

-- Execute the stored procedure
EXEC usp_LoginUser 
    @username = @username,
    @password = @password,
    @loginResult = @loginResult OUTPUT;



-- Jika login berhasil, maka akan mencetak pesan bahwa login berhasil
-- Jika login gagal, maka akan mencetak pesan kesalahan yang sesuai

--------------------------------------------
-- 4. usp_ViewUserProfile Store Procedure --
--------------------------------------------

CREATE OR ALTER PROCEDURE ViewUserProfile
    @username NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Mendapatkan informasi profil pengguna berdasarkan username
        SELECT u.user_id, u.username, u.email, up.gender, up.age, up.height, up.weight
        FROM Users u
        INNER JOIN UserProfile up ON u.user_id = up.user_id
        WHERE u.username = @username;
    END TRY
    BEGIN CATCH
        -- Menampilkan pesan kesalahan jika terjadi masalah
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO
-- Menjalankan stored procedure ViewUserProfile dengan parameter username
EXEC ViewUserProfile 
    @username = 'john_doe2';


----------------------------------------------
-- 5. usp_UpdateUserProfile Store Procedure --
----------------------------------------------
CREATE OR ALTER PROCEDURE UpdateUserProfile
    @username NVARCHAR(50),
    @email NVARCHAR(100),
    @gender NVARCHAR(10),
    @age INT,
    @height DECIMAL(5, 2),
    @weight DECIMAL(5, 2)
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Update informasi profil pengguna
        UPDATE UserProfile
        SET gender = @gender, age = @age, height = @height, weight = @weight
        FROM UserProfile up
        INNER JOIN Users u ON u.user_id = up.user_id
        WHERE u.username = @username;

        -- Update informasi email pada tabel Users
        UPDATE Users
        SET email = @email
        WHERE username = @username;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Menampilkan pesan kesalahan jika terjadi masalah
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO
-- Menjalankan stored procedure UpdateUserProfile dengan parameter yang sesuai
EXEC UpdateUserProfile 
    @username = 'john_doe',
    @email = 'john@example.com',
    @gender = 'Male',
    @age = 37,
    @height = 180.0,
    @weight = 78.0;


------------------------------------------
-- 6. usp_InsertUserBMR Store Procedure --
------------------------------------------

-----------------------------------
-- Function CalculateBMRFunction --
-----------------------------------
CREATE OR ALTER FUNCTION CalculateBMRFunction
(
    @gender NVARCHAR(10),
    @age INT,
    @weight DECIMAL(5, 2),
    @height DECIMAL(5, 2),
    @activity_level_multiplier DECIMAL(5, 2),
    @calorie_adjustment INT
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @bmr DECIMAL(10, 2)

    IF (@gender = 'Male')
    BEGIN
        SET @bmr = 66.5 + (13.75 * @weight) + (5.003 * @height) - (6.755 * @age)
    END
    ELSE
    BEGIN
        SET @bmr = 655.1 + (9.563 * @weight) + (1.850 * @height) - (4.676 * @age)
    END

    -- Adjust BMR based on activity level
    SET @bmr = @bmr * @activity_level_multiplier

    -- Adjust BMR based on target goal
    SET @bmr = @bmr + @calorie_adjustment

    RETURN @bmr
END
GO

CREATE OR ALTER PROCEDURE usp_UpdateUserBMR
    @user_id INT,
    @gender NVARCHAR(10),
    @age INT,
    @weight DECIMAL(5, 2),
    @height DECIMAL(5, 2),
    @activity_level_id INT,
    @target_goal_id INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @activity_multiplier DECIMAL(5, 2)
        DECLARE @calorie_adjustment INT

        -- Get activity multiplier based on activity level
        SELECT @activity_multiplier = activity_multiplier
        FROM ActivityLevels
        WHERE activity_id = @activity_level_id

        -- Get calorie adjustment based on target goal
        SELECT @calorie_adjustment = calorie_adjustment
        FROM TargetGoals
        WHERE goal_id = @target_goal_id

        -- Calculate BMR using the function
        DECLARE @bmr DECIMAL(10, 2)
        SET @bmr = dbo.CalculateBMRFunction(@gender, @age, @weight, @height, @activity_multiplier, @calorie_adjustment)

        -- Update BMR in UserCalorieInformation table
        UPDATE UserCalorieInformation
        SET 
			bmr = @bmr,
			activity_level_id = @activity_level_id,
			target_goal_id = @target_goal_id
        WHERE user_id = @user_id

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Handle error
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

-- Menjalankan stored procedure InsertUserBMR dengan parameter yang sesuai
EXEC usp_UpdateUserBMR
    @user_id = 10,
    @gender = 'Male',
    @age = 30,
    @weight = 80.0,
    @height = 180.0,
    @activity_level_id = 2, -- Misalnya, tingkat aktivitas sedang
    @target_goal_id = 3;     -- Misalnya, tujuan diet untuk menurunkan berat badan

SELECT*FROM UserCalorieInformation
-----------------------------------------------------------------------------
-- 6. usp_AddFoodConsumption Store Procedure & CalculateNutrition Function --
-----------------------------------------------------------------------------
CREATE OR ALTER FUNCTION CalculateNutrition
(
    @food_id NVARCHAR(50),
    @quantity DECIMAL(5, 2)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        energy_kal * @quantity / 100 AS energy_kal,
        protein_g * @quantity / 100 AS protein_g,
        fat_g * @quantity / 100 AS fat_g,
        carbs_g * @quantity / 100 AS carbs_g,
        fiber_g * @quantity / 100 AS fiber_g,
        calcium_mg * @quantity / 100 AS calcium_mg,
        fe_mg * @quantity / 100 AS fe_mg,
        natrium_mg * @quantity / 100 AS natrium_mg
    FROM FoodNutritionInfo
    WHERE food_id = @food_id
)
GO

CREATE OR ALTER PROCEDURE usp_AddFoodConsumption
    @user_id INT,
    @food_id NVARCHAR(50),
    @quantity DECIMAL(5, 2)
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY

        -- Memasukkan data konsumsi makanan ke dalam tabel DailyLogs
        INSERT INTO dbo.DailyLogs(user_id, food_id, quantity, log_date)
        SELECT
            @user_id,
            @food_id,
            @quantity,
            GETDATE()


        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Menampilkan pesan kesalahan jika terjadi masalah
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE usp_AddFoodConsumptionByName
    @user_id INT,
    @food_name NVARCHAR(100), -- Change parameter to food_name
    @quantity DECIMAL(5, 2)
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @food_id NVARCHAR(50);

        -- Get the food_id based on the provided food_name using LIKE
        SELECT @food_id = food_id
        FROM dbo.FoodNutritionInfo
        WHERE food_name LIKE @food_name + '%' -- Using LIKE for partial matching
		ORDER BY food_name ASC;

        IF @food_id IS NOT NULL
        BEGIN
            -- Insert data into DailyLogs table
            INSERT INTO dbo.DailyLogs(user_id, food_id, quantity, log_date)
            VALUES (@user_id, @food_id, @quantity, GETDATE());

            COMMIT TRANSACTION;
            PRINT 'Food consumption added successfully.';
        END
        ELSE
        BEGIN
            -- Food not found, rollback transaction
            ROLLBACK TRANSACTION;
            PRINT 'Food not found.';
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Display error message if an error occurs
        PRINT ERROR_MESSAGE();
    END CATCH
END

EXEC usp_AddFoodConsumptionByName
	@user_id = 10,
	@food_name = 'nasi',
	@quantity = 100.0


EXEC usp_AddFoodConsumption
	@user_id = 10,
	@food_id = 'CP040',
	@quantity = 50.0

EXEC usp_AddFoodConsumption
	@user_id = 10,
	@food_id = 'FP025',
	@quantity = 300.0

Select*from DailyLogs

--------------------------------------------
-- 7. usp_GetFoodNutrition StoreProcedure --
--------------------------------------------

CREATE OR ALTER PROCEDURE usp_GetFoodNutrition
    @user_id INT,
    @log_date DATE
AS
BEGIN
    -- Memilih data nutrisi berdasarkan user_id dan log_date
    SELECT 
        d.user_id,
        d.food_id,
        d.quantity,
        d.log_date,
        f.food_name,
        n.energy_kal,
        n.protein_g,
        n.fat_g,
        n.carbs_g,
        n.fiber_g,
        n.calcium_mg,
        n.fe_mg,
        n.natrium_mg
    FROM DailyLogs d
    JOIN FoodNutritionInfo f ON d.food_id = f.food_id
    CROSS APPLY dbo.CalculateNutrition(d.food_id, d.quantity) n
    WHERE d.user_id = @user_id AND d.log_date = @log_date;
END
GO

-- Menjalankan stored procedure GetFoodNutrition dengan parameter yang sesuai
EXEC usp_GetFoodNutrition 
    @user_id = 10,
    @log_date = '2024-02-22';

-------------------------------------------------
-- 8. usp_GetConsumptionReport Store Procedure --
-------------------------------------------------
-- Fungsi untuk menghitung sisa angka BMR
CREATE OR ALTER FUNCTION CalculateRemainingBMR
(
    @user_id INT,
    @total_calories DECIMAL(10, 2)
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @bmr DECIMAL(10, 2);

    -- Mendapatkan nilai BMR pengguna dari tabel UserCalorieInformation
    SELECT @bmr = bmr
    FROM UserCalorieInformation
    WHERE user_id = @user_id;

    -- Menghitung sisa angka BMR
    DECLARE @remaining_bmr DECIMAL(10, 2);
    SET @remaining_bmr = @bmr - @total_calories;

    RETURN @remaining_bmr;
END
GO

-- Stored procedure untuk melihat laporan total nutrisi dan sisa angka BMR
CREATE OR ALTER PROCEDURE usp_GetConsumptionReport
    @user_id INT,
    @log_date DATE
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Variabel untuk menyimpan total nutrisi
        DECLARE @total_energy_kal DECIMAL(10, 2),
                @total_protein_g DECIMAL(10, 2),
                @total_fat_g DECIMAL(10, 2),
                @total_carbs_g DECIMAL(10, 2),
                @total_fiber_g DECIMAL(10, 2),
                @total_calcium_mg DECIMAL(10, 2),
                @total_fe_mg DECIMAL(10, 2),
                @total_natrium_mg DECIMAL(10, 2);

        -- Menghitung total nutrisi dari konsumsi makanan pengguna pada tanggal tertentu
        SELECT 
            @total_energy_kal = SUM(FNI.energy_kal),
            @total_protein_g = SUM(FNI.protein_g),
            @total_fat_g = SUM(FNI.fat_g),
            @total_carbs_g = SUM(FNI.carbs_g),
            @total_fiber_g = SUM(FNI.fiber_g),
            @total_calcium_mg = SUM(FNI.calcium_mg),
            @total_fe_mg = SUM(FNI.fe_mg),
            @total_natrium_mg = SUM(FNI.natrium_mg)
        FROM DailyLogs DL
        INNER JOIN FoodNutritionInfo FNI ON DL.food_id = FNI.food_id
        WHERE DL.user_id = @user_id AND DL.log_date = @log_date;

        -- Mendapatkan nilai BMR pengguna dari tabel UserCalorieInformation
        DECLARE @bmr DECIMAL(10, 2);
        SELECT @bmr = bmr
        FROM UserCalorieInformation
        WHERE user_id = @user_id;

        -- Menghitung total kalori yang dikonsumsi
        DECLARE @total_calories DECIMAL(10, 2);
        SET @total_calories = @total_energy_kal;

        -- Menghitung sisa angka BMR
        DECLARE @remaining_bmr DECIMAL(10, 2);
        SET @remaining_bmr = @bmr - @total_calories;

        -- Menampilkan laporan total nutrisi dan sisa angka BMR
        SELECT 
            @total_energy_kal AS total_energy_kal,
            @total_protein_g AS total_protein_g,
            @total_fat_g AS total_fat_g,
            @total_carbs_g AS total_carbs_g,
            @total_fiber_g AS total_fiber_g,
            @total_calcium_mg AS total_calcium_mg,
            @total_fe_mg AS total_fe_mg,
            @total_natrium_mg AS total_natrium_mg,
            @remaining_bmr AS remaining_bmr;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Menampilkan pesan kesalahan jika terjadi masalah
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

EXEC usp_GetConsumptionReport 
	@user_id = 10, 
	@log_date = '2024-02-16';

-------------------------------
-- View to get weekly report --
-------------------------------

CREATE VIEW WeeklyProgressView AS
SELECT 
    U.user_id,
    DL.start_of_week,
    DL.end_of_week,
    SUM(FNI.energy_kal) AS total_energy_kal,
    SUM(FNI.protein_g) AS total_protein_g,
    SUM(FNI.fat_g) AS total_fat_g,
    SUM(FNI.carbs_g) AS total_carbs_g,
    SUM(FNI.fiber_g) AS total_fiber_g,
    SUM(FNI.calcium_mg) AS total_calcium_mg,
    SUM(FNI.fe_mg) AS total_fe_mg,
    SUM(FNI.natrium_mg) AS total_natrium_mg
FROM (
    SELECT 
        user_id,
        DATEADD(DAY, 1 - DATEPART(WEEKDAY, log_date), log_date) AS start_of_week,
        DATEADD(DAY, 7 - DATEPART(WEEKDAY, log_date), log_date) AS end_of_week,
        food_id,
        SUM(quantity) AS quantity
    FROM DailyLogs
    GROUP BY user_id, DATEADD(DAY, 1 - DATEPART(WEEKDAY, log_date), log_date), DATEADD(DAY, 7 - DATEPART(WEEKDAY, log_date), log_date), food_id
) AS DL
JOIN FoodNutritionInfo AS FNI ON DL.food_id = FNI.food_id
JOIN Users AS U ON DL.user_id = U.user_id
GROUP BY 
    U.user_id,
    DL.start_of_week,
    DL.end_of_week;


CREATE OR ALTER PROCEDURE GetWeeklyProgressReport
    @user_id INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Mengambil data dari view WeeklyProgressView untuk user_id tertentu
        SELECT *
        FROM WeeklyProgressView
        WHERE user_id = @user_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Menampilkan pesan kesalahan jika terjadi masalah
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

EXEC GetWeeklyProgressReport 
	@user_id = 10

--------------------------------------------------------------------------
-- FoodConsumptionSummaryView to display list of daily food consumption --
--------------------------------------------------------------------------

CREATE OR ALTER VIEW FoodConsumptionSummary
AS
SELECT 
    DL.log_id,
    DL.user_id,
    DL.food_id,
    DL.quantity,
	DL.log_date,
    FNI.food_name,
    CN.energy_kal AS total_energy_kcal,
    CN.protein_g AS total_protein_g,
    CN.fat_g AS total_fat_g,
    CN.carbs_g AS total_carbs_g,
    CN.fiber_g AS total_fiber_g,
    CN.calcium_mg AS total_calcium_mg,
    CN.fe_mg AS total_fe_mg,
    CN.natrium_mg AS total_natrium_mg
FROM 
    DailyLogs DL
JOIN 
    FoodNutritionInfo FNI ON DL.food_id = FNI.food_id
CROSS APPLY
    dbo.CalculateNutrition(DL.food_id, DL.quantity) AS CN;

---------------------------------------------------
-- Procedure to call FoodConsumptionSummary view --
---------------------------------------------------

CREATE OR ALTER PROCEDURE GetConsumedFoodsToday
    @user_id INT
AS
BEGIN
    DECLARE @today DATE;
    SET @today = CONVERT(DATE, GETDATE());

    SELECT *
    FROM
        FoodConsumptionSummary
    WHERE
        user_id = @user_id
        AND CONVERT(DATE, log_date) = @today;
END;


EXEC GetConsumedFoodsToday
	@user_id = 10

------------------------
--DeleteGoodLogByID SP--
------------------------

CREATE OR ALTER PROCEDURE usp_DeleteFoodLogByID
	@log_id INT
AS
BEGIN
	DELETE FROM DailyLogs WHERE 
	log_id = @log_id
END;




