Imports System.Runtime.CompilerServices
Imports NutriaryApp.BO

Public Interface INutriary
    Inherits ICrud(Of GetFoodNutrition)
    Function GetFoodNutrition(ByVal userId As Integer, ByVal logDate As DateTime) As List(Of GetFoodNutrition)

    Function AddFoodConsumption(ByVal userID As Integer, ByVal FoodID As String, ByVal quantity As Decimal)

    Function UserLogin(ByVal username As String, ByVal password As String)

    Function ViewProfile(ByVal username) As List(Of UserProfile)

End Interface
