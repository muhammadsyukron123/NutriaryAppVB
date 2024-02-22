Imports System
Imports Nutriary.DAL
Imports NutriaryApp.BO

Module Program
    Sub GetFoodNutrition()
        'getting data from GetFoodNutrition from NutriaryDAL
        Dim objNutriaryDAL As New NutriaryDAL
        Dim lstFoodNutrition As New List(Of GetFoodNutrition)
        lstFoodNutrition = objNutriaryDAL.GetFoodNutrition(10, "2024-02-22")
        For Each obj In lstFoodNutrition
            Console.WriteLine(New String("="c, 120))
            Console.WriteLine()
            Console.WriteLine("{0,-10} {1,-20} {2,-10:F2} {3,-10:F2} {4,-10:F2} {5,-10:F2} {6,-10:F2} {7,-10:F2} {8,-10:F2} {9,-10:F2}",
                  "Food ID", "Food Name".PadRight(25), "Energy", "Protein", "Fat", "Carbs", "Fiber", "Calcium", "Iron", "Sodium")

            Console.WriteLine("{0,-10} {1,-20} {2,-10:F2} {3,-10:F2} {4,-10:F2} {5,-10:F2} {6,-10:F2} {7,-10:F2} {8,-10:F2} {9,-10:F2}",
                  obj.food_id, obj.food_name.PadRight(25), obj.energy_kal, obj.protein_g, obj.fat_g, obj.carbs_g, obj.fiber_g, obj.calcium_mg, obj.fe_mg, obj.natrium_mg)
        Next
    End Sub

    Sub AddFoodConsumption()
        'inserting data from AddFoodConsumption from NutriaryDAL
        Dim objNutriaryDAL As New NutriaryDAL
        Dim result = objNutriaryDAL.AddFoodConsumption(10, "FP025", 200)
        If (result > 0) Then
            Console.WriteLine("Food consumption added successfully")
        Else
            Console.WriteLine("Failed to add food consumption")
        End If
    End Sub

    Sub UserLogin()
        'getting data from UserLogin from NutriaryDAL
        Dim objNutriaryDAL As New NutriaryDAL

        Console.WriteLine("Selamat datang di Nutriary")
        Console.Write("Masukkan username : ")
        Dim username As String = Console.ReadLine()
        Console.Write("Masukkan password : ")
        Dim password As String = Console.ReadLine()

        Dim result = objNutriaryDAL.UserLogin(username, password)
        If (result > 0) Then
            Console.WriteLine("Login Berhasil!")
            Console.WriteLine()
            ViewUserProfile(username)
        Else
            Console.WriteLine("Login failed")
        End If
    End Sub

    Sub ViewUserProfile(username As String)
        Dim objNutriaryDAL As New NutriaryDAL
        Dim lstUserProfile As New List(Of UserProfile)
        lstUserProfile = objNutriaryDAL.ViewProfile(username)
        For Each obj In lstUserProfile
            Console.WriteLine(New String("="c, 120))
            Console.WriteLine("Hello" & obj.username)
            Console.WriteLine()
            Console.WriteLine("{0,-10} {1,-20} {2,-10} {3,-10} {4,-10:F2} {5,-10:F2}",
                  "Username".PadRight(25), "Email", "Gender", "Age", "Height", "Weight")
            Console.WriteLine("{0,-10} {1,-20} {2,-10} {3,-10} {4,-10} {5,-10}",
            obj.username.PadRight(25), obj.email, obj.gender, obj.age, obj.height, obj.weight)
        Next
    End Sub

    Sub Main(args As String())

        UserLogin()


        GetFoodNutrition()
    End Sub
End Module
