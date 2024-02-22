Public Interface ICrud(Of T)
    Function Create(Of T)(ByVal obj As T) As Integer
    Function Read(Of T)(ByVal id As Integer) As T
    Function ReadAll(Of T)() As List(Of T)
    Function Update(Of T)(ByVal obj As T) As Integer
    Function Delete(Of T)(ByVal id As Integer) As Integer
End Interface
