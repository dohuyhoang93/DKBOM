' Arguments:
' in_FilePath As String
' in_NewSheetName As String
' in_NewRowNumber As Int32
' out_ErrorMessage As String

out_ErrorMessage = String.Empty
Dim newContentForLine1 As String = in_NewSheetName.Trim() & "," & in_NewRowNumber.ToString()

Try
    If Not System.IO.File.Exists(in_FilePath) Then
        out_ErrorMessage = "Lỗi: File không tồn tại tại đường dẫn: " & in_FilePath
        Return
    End If

    Dim lines As New List(Of String)(System.IO.File.ReadAllLines(in_FilePath))

    If lines.Count >= 2 Then
        ' Ghi đè dòng thứ hai (index 1)
        lines(1) = newContentForLine1
    ElseIf lines.Count = 1 Then
        ' Nếu chỉ có 1 dòng, thêm dòng mới này làm dòng thứ hai
        lines.Add(newContentForLine1)
    Else ' lines.Count = 0
        ' Nếu file rỗng, thêm một dòng trống cho dòng 0 (index 0) và dòng mới này cho dòng 1 (index 1)
        ' Hoặc bạn có thể quyết định chỉ thêm dòng mới này, tùy thuộc vào yêu cầu.
        lines.Add("") ' Dòng 0 trống
        lines.Add(newContentForLine1) ' Dòng 1 mới
    End If

    System.IO.File.WriteAllLines(in_FilePath, lines.ToArray())

Catch ex As Exception
    out_ErrorMessage = "Lỗi khi ghi đè dòng 1: " & ex.Message
End Try