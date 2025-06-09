Sub FillSubMaterial1()
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long

    ' Gán worksheet đang hoạt động
    Set ws = ActiveSheet

    ' Tìm dòng cuối cùng có dữ liệu ở cột A (hoặc cột phù hợp với dữ liệu chính)
    lastRow = ws.Cells(ws.Rows.Count, "A").End(xlUp).Row

    ' Vòng lặp từ dòng 2 đến dòng cuối
    For i = 2 To lastRow
        If i = 2 Then
            ws.Cells(i, "N").Value = "" ' Bỏ qua dòng 2
        Else
            ws.Cells(i, "N").Value = ws.Cells(i - 1, "E").Value ' Gán N(i) = E(i - 1)
        End If
    Next i
End Sub
