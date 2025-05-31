' Arguments:
' in_FilePath As String
' in_SheetToAppend As String
' out_ErrorMessage As String

out_ErrorMessage = String.Empty

Try
    If Not System.IO.File.Exists(in_FilePath) Then
        out_ErrorMessage = "Lỗi: File không tồn tại tại đường dẫn: " & in_FilePath
        Return
    End If

    Dim lines As New List(Of String)(System.IO.File.ReadAllLines(in_FilePath))
    
    While lines.Count < 2
    lines.Add("")
    End While

    If String.IsNullOrWhiteSpace(lines(0)) Then
        ' Dòng đầu rỗng
        lines(0) = in_SheetToAppend 'Ghi đè sheet đã hoàn thành vào dòng 1
        lines(1) = "" 'ghi đè dòng 2 về trạng thái rỗng
    Else
        ' File không rỗng, đã có sheet hoàn thành trước đó -> chỉ append vào dòng 0
        lines(0)= lines(0) & "," & in_SheetToAppend.Trim() 'nối sheet đã hoàn thành
        lines(1) = "" 'ghi đè dòng 2 về rỗng
    End If

    System.IO.File.WriteAllLines(in_FilePath, lines.ToArray())

Catch ex As Exception
    out_ErrorMessage = "Lỗi khi nối vào dòng 0: " & ex.Message
End Try