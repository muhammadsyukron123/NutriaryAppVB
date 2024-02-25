Imports System.Runtime.CompilerServices
Imports NutriaryApp.BO

Public Interface INutriary
    Inherits ICrud(Of GetFoodNutrition)
    Function GetFoodNutrition(ByVal userId As Integer, ByVal logDate As DateTime) As List(Of GetFoodNutrition)

    Function AddFoodConsumption(ByVal userID As Integer, ByVal FoodID As String, ByVal quantity As Decimal)

    Function AddFoodConsumptionByName(ByVal userID As Integer, ByVal FoodName As String, ByVal quantity As Decimal)

    Function UserLogin(ByVal username As String, ByVal password As String)
    Function RegisterUser(ByVal username As String, ByVal password As String, ByVal email As String)

    Function ViewProfile(ByVal username) As List(Of UserProfile)

    Function GetConsumptionReport(ByVal userId As Integer, ByVal logDate As DateTime) As List(Of ConsumptionReport)

    Function InsertUserProfile(ByVal userId As Integer, ByVal gender As String, ByVal age As Integer, ByVal height As Decimal, ByVal weight As Decimal, ByVal activityLevelID As Integer, ByVal targetGoalID As Integer)

    Function GetUserDataByUsername(ByVal username As String) As List(Of Users)

End Interface
