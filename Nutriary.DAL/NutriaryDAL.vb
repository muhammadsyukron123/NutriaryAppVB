Imports System.Data
Imports System.Data.SqlClient
Imports ICrud
Imports Microsoft.Data.SqlClient
Imports NutriaryApp.BO
Imports NutriaryApp.Interface

Public Class NutriaryDAL
    Implements INutriary

    Private strConn As String
    Private conn As SqlConnection
    Private cmd As SqlCommand
    Private dr As SqlDataReader

    Public Sub New()
        strConn = "Server=.\BSISQLEXPRESS;Database=NutriaryDatabase;Trusted_Connection=True;TrustServerCertificate=True;"
        conn = New SqlConnection(strConn)
    End Sub

    Public Function GetFoodNutrition(userId As Integer, logDate As Date) As List(Of GetFoodNutrition) Implements INutriary.GetFoodNutrition
        Try
            cmd = New SqlCommand("usp_GetFoodNutrition", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@user_id", userId) ' replace userId with the actual value
            cmd.Parameters.AddWithValue("@log_date", logDate)

            cmd.CommandType = CommandType.StoredProcedure
            conn.Open()
            dr = cmd.ExecuteReader()
            Dim lstFoodNutrition As New List(Of GetFoodNutrition)
            If dr.HasRows Then
                While dr.Read()
                    Dim obj As New GetFoodNutrition
                    obj.food_id = dr("food_id")
                    obj.food_name = dr("food_name")
                    obj.energy_kal = dr("energy_kal")
                    obj.protein_g = dr("protein_g")
                    obj.fat_g = dr("fat_g")
                    obj.carbs_g = dr("carbs_g")
                    obj.fiber_g = dr("fiber_g")
                    obj.calcium_mg = dr("calcium_mg")
                    obj.fe_mg = dr("fe_mg")
                    obj.natrium_mg = dr("natrium_mg")
                    lstFoodNutrition.Add(obj)
                End While
            End If
            Return lstFoodNutrition
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception
            Throw ex
        Finally
            cmd.Dispose()
            conn.Close()
        End Try
    End Function
    Public Function GetConsumptionReport(userId As Integer, logDate As Date) As List(Of ConsumptionReport) Implements INutriary.GetConsumptionReport
        Try
            cmd = New SqlCommand("usp_GetConsumptionReport", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@user_id", userId)
            cmd.Parameters.AddWithValue("@log_date", logDate)
            cmd.CommandType = CommandType.StoredProcedure
            conn.Open()
            dr = cmd.ExecuteReader()
            Dim lstConsumptionReport As New List(Of ConsumptionReport)
            If dr.HasRows Then
                While dr.Read()
                    Dim obj As New ConsumptionReport
                    obj.total_energy_kal = dr("total_energy_kal")
                    obj.total_protein_g = dr("total_protein_g")
                    obj.total_fat_g = dr("total_fat_g")
                    obj.total_carbs_g = dr("total_carbs_g")
                    obj.total_fiber_g = dr("total_fiber_g")
                    obj.total_calcium_mg = dr("total_calcium_mg")
                    obj.total_fe_mg = dr("total_fe_mg")
                    obj.total_natrium_mg = dr("total_natrium_mg")
                    obj.remaining_bmr = dr("remaining_bmr")
                    lstConsumptionReport.Add(obj)
                End While
            End If
            Return lstConsumptionReport
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception
            Throw ex
        Finally
            cmd.Dispose()
            conn.Close()
        End Try

    End Function


    Public Function Create(Of T)(obj As T) As Integer Implements ICrud(Of Global.NutriaryApp.BO.GetFoodNutrition).Create
        Throw New NotImplementedException()
    End Function

    Public Function Read(Of T)(id As Integer) As T Implements ICrud(Of Global.NutriaryApp.BO.GetFoodNutrition).Read
        Throw New NotImplementedException()
    End Function

    Public Function ReadAll(Of T)() As List(Of T) Implements ICrud(Of Global.NutriaryApp.BO.GetFoodNutrition).ReadAll
        Throw New NotImplementedException()
    End Function

    Public Function Update(Of T)(obj As T) As Integer Implements ICrud(Of Global.NutriaryApp.BO.GetFoodNutrition).Update
        Throw New NotImplementedException()
    End Function

    Public Function Delete(Of T)(id As Integer) As Integer Implements ICrud(Of Global.NutriaryApp.BO.GetFoodNutrition).Delete
        Throw New NotImplementedException()
    End Function

    Public Function AddFoodConsumption(userID As Integer, FoodID As String, quantity As Decimal) As Object Implements INutriary.AddFoodConsumption
        Try
            cmd = New SqlCommand("usp_AddFoodConsumption", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@user_id", userID)
            cmd.Parameters.AddWithValue("@food_id", FoodID)
            cmd.Parameters.AddWithValue("@quantity", quantity)

            conn.Open()
            Dim result = cmd.ExecuteNonQuery()
            Return result
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception
            Throw ex
        Finally
            cmd.Dispose()
            conn.Close()
        End Try

    End Function

    Public Function UserLogin(username As String, password As String) As Object Implements INutriary.UserLogin
        Try
            cmd = New SqlCommand("usp_LoginUser", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@username", username)
            cmd.Parameters.AddWithValue("@password", password)

            ' Add an output parameter to retrieve the login result
            Dim loginResultParam As New SqlParameter("@loginResult", SqlDbType.Int)
            loginResultParam.Direction = ParameterDirection.Output
            cmd.Parameters.Add(loginResultParam)

            conn.Open()
            cmd.ExecuteNonQuery()

            ' Retrieve the login result from the output parameter
            Dim loginResult As Integer = Convert.ToInt32(loginResultParam.Value)

            Return loginResult
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception
            Throw ex
        Finally
            cmd.Dispose()
            conn.Close()
        End Try
    End Function

    Public Function ViewProfile(username As Object) As List(Of UserProfile) Implements INutriary.ViewProfile
        Try
            cmd = New SqlCommand("ViewUserProfile", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@username", username)
            conn.Open()
            dr = cmd.ExecuteReader()
            Dim lstUserProfile As New List(Of UserProfile)
            If dr.HasRows Then
                While dr.Read()
                    Dim obj As New UserProfile
                    obj.userId = dr("user_id")
                    obj.username = dr("username")
                    obj.email = dr("email")
                    obj.gender = dr("gender")
                    obj.age = dr("age")
                    obj.height = dr("height")
                    obj.weight = dr("weight")
                    lstUserProfile.Add(obj)
                End While
            End If
            Return lstUserProfile
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception
        End Try
    End Function

    Public Function AddFoodConsumptionByName(userID As Integer, FoodName As String, quantity As Decimal) As Object Implements INutriary.AddFoodConsumptionByName
        Try
            cmd = New SqlCommand("usp_AddFoodConsumptionByName", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@user_id", userID)
            cmd.Parameters.AddWithValue("@food_name", FoodName)
            cmd.Parameters.AddWithValue("@quantity", quantity)

            conn.Open()
            Dim result = cmd.ExecuteNonQuery()
            Return result
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception

        End Try
    End Function

    Public Function RegisterUser(username As String, password As String, email As String) As Object Implements INutriary.RegisterUser
        Try
            cmd = New SqlCommand("usp_RegisterUser", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@username", username)
            cmd.Parameters.AddWithValue("@password", password)
            cmd.Parameters.AddWithValue("@email", email)

            conn.Open()
            Dim result = cmd.ExecuteNonQuery()
            Return result
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception
            Throw ex
        Finally
            cmd.Dispose()
            conn.Close()
        End Try
    End Function

    Public Function InsertUserProfile(userId As Integer, gender As String, age As Integer, height As Decimal, weight As Decimal, activityLevelID As Integer, targetGoalID As Integer) As Object Implements INutriary.InsertUserProfile
        Try
            cmd = New SqlCommand("usp_InsertUserProfile", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@user_id", userId)
            cmd.Parameters.AddWithValue("@gender", gender)
            cmd.Parameters.AddWithValue("@age", age)
            cmd.Parameters.AddWithValue("@height", height)
            cmd.Parameters.AddWithValue("@weight", weight)
            cmd.Parameters.AddWithValue("@activity_level_id", activityLevelID)
            cmd.Parameters.AddWithValue("@target_goal_id", targetGoalID)

            conn.Open()
            Dim result = cmd.ExecuteNonQuery()
            Return result
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception
            Throw ex
        Finally
            cmd.Dispose()
            conn.Close()
        End Try

    End Function

    Public Function GetUserDataByUsername(username As String) As List(Of Users) Implements INutriary.GetUserDataByUsername
        Try
            cmd = New SqlCommand("usp_GetUserDataByUsername", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@username", username)
            conn.Open()
            dr = cmd.ExecuteReader()
            Dim lstUsers As New List(Of Users)
            If dr.HasRows Then
                While dr.Read()
                    Dim obj As New Users
                    obj.user_id = dr("user_id")
                    obj.username = dr("username")
                    obj.email = dr("email")
                    obj.password = dr("password")
                    lstUsers.Add(obj)
                End While
            End If
            Return lstUsers
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception
            Throw ex
        Finally
            cmd.Dispose()
            conn.Close()
        End Try
    End Function

    Public Function GetDailyConsumption(userId As Integer) As List(Of GetDailyConsumedFood) Implements INutriary.GetDailyConsumption
        Try
            cmd = New SqlCommand("GetConsumedFoodsToday", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@user_id", userId)
            conn.Open()
            dr = cmd.ExecuteReader()
            Dim lstDailyConsumption As New List(Of GetDailyConsumedFood)
            If dr.HasRows Then
                While dr.Read()
                    Dim obj As New GetDailyConsumedFood
                    obj.log_id = dr("log_id")
                    obj.user_id = dr("user_id")
                    obj.food_id = dr("food_id")
                    obj.quantity = dr("quantity")
                    obj.log_date = dr("log_date")
                    obj.food_name = dr("food_name")
                    obj.total_energy_kcal = dr("total_energy_kcal")
                    obj.total_protein_g = dr("total_protein_g")
                    obj.total_fat_g = dr("total_fat_g")
                    obj.total_carbs_g = dr("total_carbs_g")
                    obj.total_fiber_g = dr("total_fiber_g")
                    obj.total_calcium_mg = dr("total_calcium_mg")
                    obj.total_fe_mg = dr("total_fe_mg")
                    obj.total_natrium_mg = dr("total_natrium_mg")
                    lstDailyConsumption.Add(obj)
                End While
            End If
            Return lstDailyConsumption
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception
            Throw ex
        Finally
            cmd.Dispose()
            conn.Close()
        End Try
    End Function

    Public Function UpdateFoodQuantity(logId As Integer, Quantity As Decimal) As Object Implements INutriary.UpdateFoodQuantity
        Try
            cmd = New SqlCommand("usp_UpdateFoodQuantity", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@log_id", logId)
            cmd.Parameters.AddWithValue("@new_quantity", Quantity)
            conn.Close()
            conn.Open()

            Dim result = cmd.ExecuteNonQuery()
            Return result
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception
            Throw ex
        Finally
            cmd.Dispose()
            conn.Close()
        End Try
    End Function



    Public Function DeleteFoodLogByID(logId As Integer) As Object Implements INutriary.DeleteFoodLogByID
        Try
            cmd = New SqlCommand("usp_DeleteFoodLog", conn)
            cmd.CommandType = CommandType.StoredProcedure
            cmd.Parameters.AddWithValue("@log_id", logId)
            conn.Open()
            Dim result = cmd.ExecuteNonQuery()
            Return result
        Catch sqlex As SqlException
            Throw New ArgumentException(sqlex.Message & " " & sqlex.Number)
        Catch ex As Exception
            Throw ex
        Finally
            cmd.Dispose()
            conn.Close()
        End Try
    End Function
End Class
