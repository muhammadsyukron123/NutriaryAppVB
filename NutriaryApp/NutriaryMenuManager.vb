﻿Imports Nutriary.DAL
Imports NutriaryApp.BO

Public Class NutriaryMenuManager
    Public Shared Sub GetFoodNutrition(userId As Integer)
        'getting data from GetFoodNutrition from NutriaryDAL
        Dim objNutriaryDAL As New NutriaryDAL
        Dim lstFoodNutrition As New List(Of GetFoodNutrition)
        lstFoodNutrition = objNutriaryDAL.GetFoodNutrition(userId, Date.Now)
        For Each obj In lstFoodNutrition
            Console.WriteLine(New String("="c, 120))
            Console.WriteLine()
            Console.WriteLine("{0,-10} {1,-20} {2,-10:F2} {3,-10:F2} {4,-10:F2} {5,-10:F2} {6,-10:F2} {7,-10:F2} {8,-10:F2} {9,-10:F2}",
                  "Food ID", "Food Name".PadRight(30), "Energy", "Protein", "Fat", "Carbs", "Fiber", "Calcium", "Iron", "Sodium")

            Console.WriteLine("{0,-10} {1,-20} {2,-10:F2} {3,-10:F2} {4,-10:F2} {5,-10:F2} {6,-10:F2} {7,-10:F2} {8,-10:F2} {9,-10:F2}",
                  obj.food_id, obj.food_name.PadRight(30), obj.energy_kal, obj.protein_g, obj.fat_g, obj.carbs_g, obj.fiber_g, obj.calcium_mg, obj.fe_mg, obj.natrium_mg)
        Next
    End Sub

    Public Shared Sub AddFoodConsumption()
        'inserting data from AddFoodConsumption from NutriaryDAL
        Dim objNutriaryDAL As New NutriaryDAL
        Dim result = objNutriaryDAL.AddFoodConsumption(10, "FP025", 200)
        If (result > 0) Then
            Console.WriteLine("Food consumption added successfully")
        Else
            Console.WriteLine("Failed to add food consumption")
        End If
    End Sub

    Public Shared Sub AddFoodConsumptionByName(userId As Integer)
        Console.WriteLine("Menambahkan food consumption berdasarkan nama makanan")
        Console.WriteLine("Masukkan nama makanan")
        Dim foodName As String = Console.ReadLine()
        Console.WriteLine("Masukkan jumlah makanan")
        Dim quantity As Decimal = Console.ReadLine()


        'inserting data from AddFoodConsumptionByName from NutriaryDAL
        Dim objNutriaryDAL As New NutriaryDAL
        Dim result = objNutriaryDAL.AddFoodConsumptionByName(userId, foodName, quantity)
        If (result > 0) Then
            Console.WriteLine("Food consumption added successfully")
        Else
            Console.WriteLine("Failed to add food consumption")
        End If
    End Sub

    Public Shared Sub GetConsumptionReport(userId As Integer)
        ' Getting data from GetConsumptionReport from NutriaryDAL
        Dim objNutriaryDAL As New NutriaryDAL
        Dim lstConsumptionReport As New List(Of ConsumptionReport)
        lstConsumptionReport = objNutriaryDAL.GetConsumptionReport(userId, Date.Now)

        ' Printing the report
        For Each obj In lstConsumptionReport
            Console.WriteLine(New String("="c, 120))
            Console.WriteLine()
            Console.WriteLine("Total Energy : " & obj.total_energy_kal)
            Console.WriteLine("Total Protein : " & obj.total_protein_g)
            Console.WriteLine("Total Fat : " & obj.total_fat_g)
            Console.WriteLine("Total Carbs : " & obj.total_carbs_g)
            Console.WriteLine("Total Fiber : " & obj.total_fiber_g)
            Console.WriteLine("Total Calcium : " & obj.total_calcium_mg)
            Console.WriteLine("Total Iron : " & obj.total_fe_mg)
            Console.WriteLine("Total Sodium : " & obj.total_natrium_mg)
            Console.WriteLine("Remaining BMR : " & obj.remaining_bmr)

        Next

    End Sub


    Public Shared Sub UserLogin()
        'getting data from UserLogin from NutriaryDAL
        Dim objNutriaryDAL As New NutriaryDAL

        Console.WriteLine("Silahkan login menggunakan username dan password anda")
        Console.Write("Masukkan username : ")
        Dim username As String = Console.ReadLine()
        Console.Write("Masukkan password : ")
        Dim password As New System.Text.StringBuilder()
        Do
            Dim key = Console.ReadKey(intercept:=True)
            If key.Key = ConsoleKey.Enter Then
                Exit Do
            ElseIf key.Key = ConsoleKey.Backspace AndAlso password.Length > 0 Then
                password.Remove(password.Length - 1, 1)
                Console.Write(vbBack & " " & vbBack)
            ElseIf key.KeyChar <> vbBack Then
                password.Append(key.KeyChar)
                Console.Write("*")
            End If

        Loop


        Dim result = objNutriaryDAL.UserLogin(username, password.ToString)
        If (result > 0) Then
            Console.WriteLine()
            Console.WriteLine("Login Berhasil!")
            Console.WriteLine()
            NutriaryMenu(username)
        Else
            Console.WriteLine("Login failed")
        End If
    End Sub

    Public Shared Sub ViewUserProfile(username As String)
        Dim objNutriaryDAL As New NutriaryDAL
        Dim lstUserProfile As New List(Of UserProfile)
        lstUserProfile = objNutriaryDAL.ViewProfile(username)
        For Each obj In lstUserProfile
            Console.WriteLine(New String("="c, 120))
            Console.WriteLine("Hello " & obj.username)
            Console.WriteLine()

            Console.WriteLine("Username : " & obj.username)
            Console.WriteLine("Email : " & obj.email)
            Console.WriteLine("Gender : " & obj.gender)
            Console.WriteLine("Age : " & obj.age)
            Console.WriteLine("Height : " & obj.height)
            Console.WriteLine("Weight : " & obj.weight)
            Console.WriteLine(New String("="c, 120))
        Next

    End Sub

    Public Shared Sub RegisterUser()
        Dim objNutriaryDAL As New NutriaryDAL
        Dim lstUserProfile As New List(Of Users)
        Console.WriteLine("Silahkan isi data berikut untuk membuat akun")
        Console.Write("Masukkan username : ")
        Dim username As String = Console.ReadLine()
        Console.Write("Masukkan email : ")
        Dim email As String = Console.ReadLine()
        Console.Write("Masukkan password : ")
        Dim password As New System.Text.StringBuilder()
        Do
            Dim key = Console.ReadKey(intercept:=True)
            If key.Key = ConsoleKey.Enter Then
                Exit Do
            ElseIf key.Key = ConsoleKey.Backspace AndAlso password.Length > 0 Then
                password.Remove(password.Length - 1, 1)
                Console.Write(vbBack & " " & vbBack)
            ElseIf key.KeyChar <> vbBack Then
                password.Append(key.KeyChar)
                Console.Write("*")
            End If

        Loop
        Console.WriteLine()

        Dim result = objNutriaryDAL.RegisterUser(username, password.ToString, email)
        If (result > 0) Then
            Console.WriteLine("Akun berhasil dibuat!")
            lstUserProfile = objNutriaryDAL.GetUserDataByUsername(username)
            For Each obj In lstUserProfile
                InsertUserProfile(obj.user_id)
                Console.WriteLine(obj.user_id)
            Next
        Else
            Console.WriteLine("Gagal membuat akun")
        End If
    End Sub

    Public Shared Sub NutriaryMenu(username As String)
        Dim objNutriaryDAL As New NutriaryDAL
        Dim lstUserProfile As New List(Of UserProfile)
        lstUserProfile = objNutriaryDAL.ViewProfile(username)

        Dim exitMenu As Boolean = False
        While Not exitMenu
            Console.WriteLine()
            Console.WriteLine("Selamat datang " & username)
            Console.WriteLine("1. Lihat profil")
            Console.WriteLine("2. Edit Profil")
            Console.WriteLine("3. Lihat daftar konsumsi makanan")
            Console.WriteLine("4. Lihat laporan konsumsi makanan anda")
            Console.WriteLine("5. Tambahkan konsumsi makanan")
            Console.WriteLine("6. Keluar")
            Console.Write("Pilih menu : ")
            Dim menu As Integer = Console.ReadLine()
            Select Case menu
                Case 1
                    ViewUserProfile(username)
                Case 2
                    For Each obj In lstUserProfile
                        UpdateUserProfile(obj.userId)
                    Next
                Case 3
                    For Each obj In lstUserProfile
                        GetFoodNutrition(obj.userId)
                    Next
                Case 4
                    For Each obj In lstUserProfile
                        GetConsumptionReport(obj.userId)
                    Next
                Case 5
                    For Each obj In lstUserProfile
                        AddFoodConsumptionByName(obj.userId)
                    Next
                Case 6
                    exitMenu = True
                    Environment.Exit(0)
            End Select
        End While
    End Sub


    Public Shared Sub InitialMenu()
        Dim exitApp As Boolean = False
        While Not exitApp
            Console.WriteLine("Selamat datang di Nutriary !")
            Console.WriteLine("1. Buat Akun")
            Console.WriteLine("2. Login")
            Console.WriteLine("3. Keluar")
            Console.Write("Pilih menu : ")
            Dim menu As Integer = Console.ReadLine()
            Select Case menu
                Case 1
                    RegisterUser()
                Case 2
                    UserLogin()
                Case 3
                    exitApp = True
                    Environment.Exit(0)
            End Select
        End While
    End Sub

    Public Shared Sub InsertUserProfile(userId As Integer)
        Dim objNutriaryDAL As New NutriaryDAL
        Console.WriteLine("Silahkan isi data berikut untuk membuat akun")
        Console.Write("Masukkan Jenis Kelamin Anda (Male/Female) : ")
        Dim gender As String = Console.ReadLine()
        Console.Write("Masukkan Umur Anda : ")
        Dim age As Integer = Console.ReadLine()
        Console.Write("Masukkan Tinggi Badan Anda : ")
        Dim height As Decimal = Console.ReadLine()
        Console.Write("Masukkan Berat Badan Anda : ")
        Dim weight As Decimal = Console.ReadLine()
        Console.WriteLine("Tingkat Aktivitas :")
        Console.WriteLine("1. Tidak Aktif")
        Console.WriteLine("2. Sedikit Aktif")
        Console.WriteLine("3. Aktif")
        Console.WriteLine("4. Sangat Aktif")
        Console.WriteLine("5. Ekstra Aktif")
        Console.Write("Masukkan Tingkat Aktivitas Anda (1-5) : ")
        Dim activityLevelID As Integer = Console.ReadLine()
        Console.WriteLine("Target Goal :")
        Console.WriteLine("1. Menambah Berat Badan")
        Console.WriteLine("2. Menjaga Berat Badan")
        Console.WriteLine("3. Mengurangi Berat Badan")
        Console.Write("Masukkan Target Goal Anda (1-3) : ")
        Dim targetGoalID As Integer = Console.ReadLine()

        Dim result = objNutriaryDAL.InsertUserProfile(userId, gender, age, height, weight, activityLevelID, targetGoalID)
        If (result > 0) Then
            Console.WriteLine("Profil berhasil dibuat!")
        Else
            Console.WriteLine("Gagal membuat profil")
        End If

    End Sub

    Public Shared Sub UpdateUserProfile(userId As Integer)
        Dim objNutriaryDAL As New NutriaryDAL
        Console.WriteLine("Silahkan isi data berikut untuk mengupdate profil anda")
        Console.Write("Masukkan Jenis Kelamin Anda (Male/Female) : ")
        Dim gender As String = Console.ReadLine()
        Console.Write("Masukkan Umur Anda : ")
        Dim age As Integer = Console.ReadLine()
        Console.Write("Masukkan Tinggi Badan Anda : ")
        Dim height As Decimal = Console.ReadLine()
        Console.Write("Masukkan Berat Badan Anda : ")
        Dim weight As Decimal = Console.ReadLine()
        Console.WriteLine("Tingkat Aktivitas :")
        Console.WriteLine("1. Tidak Aktif")
        Console.WriteLine("2. Sedikit Aktif")
        Console.WriteLine("3. Aktif")
        Console.WriteLine("4. Sangat Aktif")
        Console.WriteLine("5. Ekstra Aktif")
        Console.Write("Masukkan Tingkat Aktivitas Anda (1-5) : ")
        Dim activityLevelID As Integer = Console.ReadLine()
        Console.WriteLine("Target Goal :")
        Console.WriteLine("1. Menambah Berat Badan")
        Console.WriteLine("2. Menjaga Berat Badan")
        Console.WriteLine("3. Mengurangi Berat Badan")
        Console.Write("Masukkan Target Goal Anda (1-3) : ")
        Dim targetGoalID As Integer = Console.ReadLine()

        Dim result = objNutriaryDAL.InsertUserProfile(userId, gender, age, height, weight, activityLevelID, targetGoalID)
        If (result > 0) Then
            Console.WriteLine("Profil berhasil diupdate!")
        Else
            Console.WriteLine("Gagal mengupdate profil")
        End If
    End Sub

End Class
