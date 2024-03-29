USE [NutriaryDatabase]
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateBMRFunction]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[CalculateBMRFunction]
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
/****** Object:  UserDefinedFunction [dbo].[CalculateRemainingBMR]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CalculateRemainingBMR]
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
/****** Object:  Table [dbo].[DailyLogs]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DailyLogs](
	[log_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[food_id] [nvarchar](50) NOT NULL,
	[quantity] [decimal](5, 2) NOT NULL,
	[log_date] [date] NOT NULL,
 CONSTRAINT [PK__DailyLog__9E2397E04EDBF15D] PRIMARY KEY CLUSTERED 
(
	[log_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FoodNutritionInfo]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FoodNutritionInfo](
	[food_id] [nvarchar](50) NOT NULL,
	[food_name] [nvarchar](50) NOT NULL,
	[energy_kal] [decimal](5, 2) NOT NULL,
	[protein_g] [decimal](5, 2) NOT NULL,
	[fat_g] [decimal](5, 2) NOT NULL,
	[carbs_g] [decimal](5, 2) NOT NULL,
	[fiber_g] [decimal](5, 2) NOT NULL,
	[calcium_mg] [decimal](5, 2) NOT NULL,
	[fe_mg] [decimal](5, 2) NOT NULL,
	[natrium_mg] [decimal](5, 2) NOT NULL,
 CONSTRAINT [PK_FoodNutritionInfo] PRIMARY KEY CLUSTERED 
(
	[food_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[user_id] [int] IDENTITY(1,1) NOT NULL,
	[username] [nvarchar](50) NOT NULL,
	[email] [nvarchar](100) NOT NULL,
	[password] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK__Users__B9BE370FC263C3F0] PRIMARY KEY CLUSTERED 
(
	[user_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[WeeklyProgressView]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[WeeklyProgressView] AS
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
GO
/****** Object:  View [dbo].[ConsumedFoodsView]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-------------------------------

CREATE VIEW [dbo].[ConsumedFoodsView]
AS
SELECT
    DL.log_id,
    DL.user_id,
    DL.food_id,
    FNI.food_name,
    DL.quantity,
    DL.log_date
FROM
    DailyLogs DL
INNER JOIN
    FoodNutritionInfo FNI ON DL.food_id = FNI.food_id;
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateNutrition]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[CalculateNutrition]
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
/****** Object:  View [dbo].[FoodConsumptionSummary]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[FoodConsumptionSummary]
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
GO
/****** Object:  Table [dbo].[ActivityLevels]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActivityLevels](
	[activity_id] [int] IDENTITY(1,1) NOT NULL,
	[activity_name] [nvarchar](50) NOT NULL,
	[activity_multiplier] [decimal](5, 2) NOT NULL,
 CONSTRAINT [PK__Activity__482FBD63D29234C2] PRIMARY KEY CLUSTERED 
(
	[activity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TargetGoals]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TargetGoals](
	[goal_id] [int] IDENTITY(1,1) NOT NULL,
	[goal_name] [nvarchar](50) NOT NULL,
	[calorie_adjustment] [int] NOT NULL,
 CONSTRAINT [PK__TargetGo__76679A24D4D6967A] PRIMARY KEY CLUSTERED 
(
	[goal_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserCalorieInformation]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserCalorieInformation](
	[calorie_info_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[activity_level_id] [int] NOT NULL,
	[target_goal_id] [int] NOT NULL,
	[bmr] [decimal](10, 2) NULL,
 CONSTRAINT [PK__UserCalo__3D49CC5F0A704D6D] PRIMARY KEY CLUSTERED 
(
	[calorie_info_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserProfile]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserProfile](
	[profile_id] [int] IDENTITY(1,1) NOT NULL,
	[user_id] [int] NOT NULL,
	[gender] [nvarchar](10) NOT NULL,
	[age] [int] NOT NULL,
	[height] [decimal](5, 2) NOT NULL,
	[weight] [decimal](5, 2) NOT NULL,
 CONSTRAINT [PK__UserProf__AEBB701F948C8E48] PRIMARY KEY CLUSTERED 
(
	[profile_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DailyLogs]  WITH CHECK ADD  CONSTRAINT [FK__DailyLogs__food___37A5467C] FOREIGN KEY([food_id])
REFERENCES [dbo].[FoodNutritionInfo] ([food_id])
GO
ALTER TABLE [dbo].[DailyLogs] CHECK CONSTRAINT [FK__DailyLogs__food___37A5467C]
GO
ALTER TABLE [dbo].[DailyLogs]  WITH CHECK ADD  CONSTRAINT [FK__DailyLogs__user___36B12243] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[DailyLogs] CHECK CONSTRAINT [FK__DailyLogs__user___36B12243]
GO
ALTER TABLE [dbo].[UserCalorieInformation]  WITH CHECK ADD  CONSTRAINT [FK__UserCalor__activ__31EC6D26] FOREIGN KEY([activity_level_id])
REFERENCES [dbo].[ActivityLevels] ([activity_id])
GO
ALTER TABLE [dbo].[UserCalorieInformation] CHECK CONSTRAINT [FK__UserCalor__activ__31EC6D26]
GO
ALTER TABLE [dbo].[UserCalorieInformation]  WITH CHECK ADD  CONSTRAINT [FK__UserCalor__targe__32E0915F] FOREIGN KEY([target_goal_id])
REFERENCES [dbo].[TargetGoals] ([goal_id])
GO
ALTER TABLE [dbo].[UserCalorieInformation] CHECK CONSTRAINT [FK__UserCalor__targe__32E0915F]
GO
ALTER TABLE [dbo].[UserCalorieInformation]  WITH CHECK ADD  CONSTRAINT [FK__UserCalor__user___30F848ED] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[UserCalorieInformation] CHECK CONSTRAINT [FK__UserCalor__user___30F848ED]
GO
ALTER TABLE [dbo].[UserProfile]  WITH CHECK ADD  CONSTRAINT [FK__UserProfi__user___2A4B4B5E] FOREIGN KEY([user_id])
REFERENCES [dbo].[Users] ([user_id])
GO
ALTER TABLE [dbo].[UserProfile] CHECK CONSTRAINT [FK__UserProfi__user___2A4B4B5E]
GO
/****** Object:  StoredProcedure [dbo].[GetConsumedFoodsOnDate]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetConsumedFoodsOnDate]
    @user_id INT,
    @date DATE
AS
BEGIN
    SELECT
        log_id,
        user_id,
        food_id,
        food_name,
        quantity,
        log_date
    FROM
        ConsumedFoodsView
    WHERE
        user_id = @user_id
        AND CONVERT(DATE, log_date) = @date;
END;
GO
/****** Object:  StoredProcedure [dbo].[GetConsumedFoodsToday]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetConsumedFoodsToday]
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
GO
/****** Object:  StoredProcedure [dbo].[GetConsumptionReport]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Stored procedure untuk melihat laporan total nutrisi dan sisa angka BMR
CREATE PROCEDURE [dbo].[GetConsumptionReport]
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
/****** Object:  StoredProcedure [dbo].[GetWeeklyProgressReport]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[GetWeeklyProgressReport]
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
/****** Object:  StoredProcedure [dbo].[UpdateUserBMR]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[UpdateUserBMR]
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
        SET bmr = @bmr
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
/****** Object:  StoredProcedure [dbo].[UpdateUserProfile]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateUserProfile]
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
/****** Object:  StoredProcedure [dbo].[usp_AddFoodConsumption]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_AddFoodConsumption]
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
/****** Object:  StoredProcedure [dbo].[usp_AddFoodConsumptionByName]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_AddFoodConsumptionByName]
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
GO
/****** Object:  StoredProcedure [dbo].[usp_DeleteFoodLog]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_DeleteFoodLog]
    @log_id INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Periksa apakah log_id ada dalam tabel DailyLogs
        IF EXISTS (SELECT 1 FROM DailyLogs WHERE log_id = @log_id)
        BEGIN
            -- Hapus log makanan berdasarkan log_id
            DELETE FROM DailyLogs
            WHERE log_id = @log_id;

            COMMIT TRANSACTION;
            PRINT 'Log makanan berhasil dihapus.';
        END
        ELSE
        BEGIN
            -- Jika log_id tidak ditemukan, kirimkan pesan kesalahan
            THROW 51000, 'Log ID tidak ditemukan dalam tabel DailyLogs.', 1;
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Tangani error
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_GetConsumptionReport]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Stored procedure untuk melihat laporan total nutrisi dan sisa angka BMR
CREATE   PROCEDURE [dbo].[usp_GetConsumptionReport]
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
			@total_energy_kal = ISNULL(SUM(FNI.energy_kal), 0),
			@total_protein_g = ISNULL(SUM(FNI.protein_g), 0),
			@total_fat_g = ISNULL(SUM(FNI.fat_g), 0),
			@total_carbs_g = ISNULL(SUM(FNI.carbs_g), 0),
			@total_fiber_g = ISNULL(SUM(FNI.fiber_g), 0),
			@total_calcium_mg = ISNULL(SUM(FNI.calcium_mg), 0),
			@total_fe_mg = ISNULL(SUM(FNI.fe_mg), 0),
			@total_natrium_mg = ISNULL(SUM(FNI.natrium_mg), 0)
		FROM DailyLogs DL
		LEFT JOIN FoodNutritionInfo FNI ON DL.food_id = FNI.food_id
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
/****** Object:  StoredProcedure [dbo].[usp_GetDailyConsumedFoods]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_GetDailyConsumedFoods]
    @user_id INT
AS
BEGIN
    SELECT
        log_id,
        user_id,
        food_id,
        food_name,
        quantity,
        log_date
    FROM
        ConsumedFoodsView
    WHERE
        user_id = @user_id
		OR
		log_date = GETDATE();
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_GetFoodNutrition]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_GetFoodNutrition]
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
/****** Object:  StoredProcedure [dbo].[usp_GetUserDataByUsername]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_GetUserDataByUsername]
    @username NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        -- Mengambil data dari tabel Users berdasarkan username
        SELECT *
        FROM Users
        WHERE username = @username;
    END TRY
    BEGIN CATCH
        -- Menampilkan pesan kesalahan jika terjadi masalah
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_GetUserFoodConsumptionPerWeek]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_GetUserFoodConsumptionPerWeek]
    @user_id INT
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @Today DATE;
        SET @Today = GETDATE();

        DECLARE @StartDate DATE;
        SET @StartDate = DATEADD(DAY, -7, @Today); -- Ambil tanggal 7 hari sebelum hari ini

        DECLARE @EndDate DATE;
        SET @EndDate = @Today; -- Hari ini

        -- Mendapatkan data konsumsi makanan pengguna per hari per minggu
        SELECT
            dl.log_date AS consumption_date,
            dl.quantity,
            f.food_name,
            f.energy_kal,
            f.protein_g,
            f.fat_g,
            f.carbs_g,
            f.fiber_g,
            f.calcium_mg,
            f.fe_mg,
            f.natrium_mg
        FROM
            DailyLogs dl
        INNER JOIN
            FoodNutritionInfo f ON dl.food_id = f.food_id
        WHERE
            dl.user_id = @user_id
            AND dl.log_date BETWEEN @StartDate AND @EndDate;

        -- Menghitung sisa BMR per harinya
        DECLARE @TotalCaloriesConsumed FLOAT;
        DECLARE @BMR FLOAT;
        DECLARE @DailyCalorieLimit FLOAT;
        DECLARE @RemainingBMR FLOAT;

        -- Menghitung total kalori yang dikonsumsi pengguna per hari
        SELECT
            @TotalCaloriesConsumed = SUM(dl.quantity * f.energy_kal)
        FROM
            DailyLogs dl
        INNER JOIN
            FoodNutritionInfo f ON dl.food_id = f.food_id
        WHERE
            dl.user_id = @user_id
            AND dl.log_date BETWEEN @StartDate AND @EndDate;

        -- Mendapatkan BMR dan daily calorie limit pengguna
        SELECT
            @BMR = bmr
        FROM
            UserCalorieInformation
        WHERE
            user_id = @user_id;

        -- Menghitung sisa BMR per harinya
        SET @RemainingBMR = @DailyCalorieLimit - @TotalCaloriesConsumed;

        -- Tampilkan informasi sisa BMR per harinya
        SELECT
            @RemainingBMR AS remaining_bmr;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Tangani error di sini
        THROW;
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InsertUserBMR]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_InsertUserBMR]
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

        -- Insert BMR into UserCalorieInformation table
        INSERT INTO UserCalorieInformation (user_id, bmr)
        VALUES (@user_id, @bmr)

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Handle error
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_InsertUserProfile]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_InsertUserProfile]
    @user_id INT,
    @gender NVARCHAR(10),
    @age INT,
    @height DECIMAL(5, 2),
    @weight DECIMAL(5, 2),
    @activity_level_id INT,
    @target_goal_id INT
AS
BEGIN
    DECLARE @bmr DECIMAL(10, 2);
    DECLARE @activity_multiplier DECIMAL(5, 2);
    DECLARE @calorie_adjustment INT;

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

            -- Get activity multiplier based on activity level
            SELECT @activity_multiplier = activity_multiplier
            FROM ActivityLevels
            WHERE activity_id = @activity_level_id;

            -- Get calorie adjustment based on target goal
            SELECT @calorie_adjustment = calorie_adjustment
            FROM TargetGoals
            WHERE goal_id = @target_goal_id;

            -- Calculate BMR using the function
            SET @bmr = dbo.CalculateBMRFunction(@gender, @age, @weight, @height, @activity_multiplier, @calorie_adjustment);

            -- Update BMR in UserCalorieInformation table
            UPDATE UserCalorieInformation
            SET 
                bmr = @bmr,
                activity_level_id = @activity_level_id,
                target_goal_id = @target_goal_id
            WHERE user_id = @user_id;
        END
        ELSE
        BEGIN
            -- Jika belum ada, lakukan insert baru
            INSERT INTO UserProfile (user_id, gender, age, height, weight)
            VALUES (@user_id, @gender, @age, @height, @weight);

            -- Get activity multiplier based on activity level
            SELECT @activity_multiplier = activity_multiplier
            FROM ActivityLevels
            WHERE activity_id = @activity_level_id;

            -- Get calorie adjustment based on target goal
            SELECT @calorie_adjustment = calorie_adjustment
            FROM TargetGoals
            WHERE goal_id = @target_goal_id;

            -- Calculate BMR using the function
            SET @bmr = dbo.CalculateBMRFunction(@gender, @age, @weight, @height, @activity_multiplier, @calorie_adjustment);

            -- Insert data into UserCalorieInformation table
            INSERT INTO UserCalorieInformation (user_id, bmr, activity_level_id, target_goal_id)
            VALUES (@user_id, @bmr, @activity_level_id, @target_goal_id);
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Tangani error di sini
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO
/****** Object:  StoredProcedure [dbo].[usp_LoginUser]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_LoginUser]
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
GO
/****** Object:  StoredProcedure [dbo].[usp_RegisterUser]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_RegisterUser]
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
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateFoodQuantity]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[usp_UpdateFoodQuantity]
    @log_id INT,
    @new_quantity DECIMAL(10, 2)
AS
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Periksa apakah log_id ada dalam tabel DailyLogs
        IF EXISTS (SELECT 1 FROM DailyLogs WHERE log_id = @log_id)
        BEGIN
            -- Update quantity makanan
            UPDATE DailyLogs
            SET quantity = @new_quantity
            WHERE log_id = @log_id;

            COMMIT TRANSACTION;
            PRINT 'Quantity makanan berhasil diperbarui.';
        END
        ELSE
        BEGIN
            -- Jika log_id tidak ditemukan, kirimkan pesan kesalahan
            THROW 51000, 'Log ID tidak ditemukan dalam tabel DailyLogs.', 1;
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Tangani error
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[usp_UpdateUserBMR]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [dbo].[usp_UpdateUserBMR]
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
/****** Object:  StoredProcedure [dbo].[ViewUserProfile]    Script Date: 2/25/2024 7:39:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[ViewUserProfile]
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
