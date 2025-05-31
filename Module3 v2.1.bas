Attribute VB_Name = "Module3"
Sub Run()
    Dim ws As Worksheet
    Dim newWs As Worksheet
    Dim productName As String
    Dim phanLoai As String
    Dim cleanProductCode As String
    Dim lastRow As Long
    Dim stepsCount As Integer
    Dim i As Long, j As Long, k As Long
    Dim stepName As String
    Dim stepSymbol As String
    Dim workCenter As String
    Dim khoXuat As String
    Dim khoNhap As String
    Dim stepNameNext As String
    Dim workCenterNext As String
    Dim col As Integer  ' Bien theo doi cot hien tai cho Sub Material
    
    Application.ScreenUpdating = False
    
    ' Sheet Nhap Lieu
    Set ws = Worksheets("Nhap Lieu")
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    
    ' Loop through cells with values in column 1
    For i = 2 To lastRow
        productName = ws.Cells(i, 1).Value
        phanLoai = ws.Cells(i, 2).Value
        If productName <> "" Then
            ' Clean the product name to remove invalid characters and limit the length
            cleanProductName = CleanSheetName(productName)
            
            ' Create new sheet with the cleaned name
            On Error Resume Next
            Set newWs = Worksheets(cleanProductName)
            On Error GoTo 0
            If newWs Is Nothing Then
                Set newWs = Worksheets.Add(After:=Worksheets(Worksheets.Count))
                newWs.name = cleanProductName
            End If
            
            ' Column headers
            newWs.Cells(1, 1).Value = "Product name"
            newWs.Cells(1, 2).Value = "Phan loai"
            newWs.Cells(1, 3).Value = "Step name"
            newWs.Cells(1, 4).Value = "Item name"
            newWs.Cells(1, 5).Value = "Don vi tieu chuan"
            newWs.Cells(1, 6).Value = "Muc dich SX"
            newWs.Cells(1, 7).Value = "Ma code KH"
            newWs.Cells(1, 8).Value = "Phan loai nho"
            newWs.Cells(1, 9).Value = "Kho xuat"
            newWs.Cells(1, 10).Value = "Kho nhap"
            newWs.Cells(1, 11).Value = "Work center"
            newWs.Cells(1, 12).Value = "Time"
            
            ' Tao 30 cap cot "Sub Material" & "Sub Material Unit"
            col = 13
            Dim pairIndex As Integer
            For pairIndex = 1 To 30
                newWs.Cells(1, col).Value = "Sub Material " & pairIndex
                newWs.Cells(1, col + 1).Value = "Unit " & pairIndex
                col = col + 2
            Next pairIndex
            
            ' Check how many steps for each product_name
            stepsCount = 0
            For j = 8 To ws.Cells(i, ws.Columns.Count).End(xlToLeft).Column
                If ws.Cells(i, j).Value <> "" Then
                    stepsCount = stepsCount + 1
                End If
            Next j
            
            ' Fill in data for each step
            For k = 1 To stepsCount
                stepName = ws.Cells(i, 7 + k).Value
                stepSymbol = getSymbol(stepName)
                workCenter = getWorkCenter(stepName)
                khoXuat = getKho(workCenter)
                stepNameNext = ws.Cells(i, 7 + k + 1).Value
                workCenterNext = getWorkCenter(stepNameNext)
                khoNhap = getKho(workCenterNext)

                newWs.Cells(k + 1, 1).Value = productName
                newWs.Cells(k + 1, 2).Value = phanLoai
                newWs.Cells(k + 1, 3).Value = stepName
                newWs.Cells(k + 1, 4).Value = productName & "-" & stepSymbol
                newWs.Cells(k + 1, 5).Value = ws.Cells(i, 4).Value 'Don vi tieu chuan
                newWs.Cells(k + 1, 6).Value = ws.Cells(i, 5).Value 'Muc dich SX
                newWs.Cells(k + 1, 7).Value = ws.Cells(i, 6).Value 'Ma code KH
                newWs.Cells(k + 1, 8).Value = ws.Cells(i, 7).Value 'Phan loai nho
                newWs.Cells(k + 1, 9).Value = khoXuat
                newWs.Cells(k + 1, 10).Value = khoNhap
                newWs.Cells(k + 1, 11).Value = workCenter
                
                ' Map Sub Material 1 from previous item code
                If k = 1 Then
                    ' newWs.Cells(k + 1, 12).Value = ""
                Else
                    newWs.Cells(k + 1, 13).Value = newWs.Cells(k, 4).Value
                    newWs.Cells(k + 1, 14).Value = "1"
                End If
            Next k

            ' Xu ly voi hang Finished Goood
            If ws.Cells(i, 2).Value = "FG (Finished Good)" Then
                ' lastRow = newWs.Cells(newWs.Rows.Count, 1).End(xlUp).Row + 1 ' Xac dinh dong moi
                lastRow = k + 1
                stepName = ws.Cells(i, 3).Value
                ' Them dong moi
                newWs.Cells(lastRow, 1).Value = productName
                newWs.Cells(lastRow, 2).Value = phanLoai
                newWs.Cells(lastRow, 4).Value = stepName
                newWs.Cells(lastRow, 13).Value = newWs.Cells(lastRow - 1, 4).Value
                newWs.Cells(lastRow, 14).Value = "1"

            End If
            
            ' Create dropdowns for "Kho xuat", "Kho nhap" and "Work Center"
            CreateDropdowns newWs, stepsCount
            
            ' Automatically resize columns to fit content
            newWs.Columns.AutoFit
            
            Set newWs = Nothing
        End If
    Next i
    
    Application.ScreenUpdating = True
    MsgBox "Complete"
End Sub

' Function to clean sheet name by removing invalid characters and limit length
Function CleanSheetName(ByVal name As String) As String
    Dim invalidChars As String
    Dim c As String
    invalidChars = ":\/?*[]"
    
    ' Remove invalid characters
    For i = 1 To Len(invalidChars)
        c = Mid(invalidChars, i, 1)
        name = Replace(name, c, "")
    Next i
    
    ' Limit length to 31 characters
    If Len(name) > 31 Then name = Left(name, 31)
    
    CleanSheetName = name
End Function

Function getSymbol(stepName As String) As String
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Set ws = Worksheets("Danh Sach Cong Doan")
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    For i = 2 To lastRow
        If ws.Cells(i, 1).Value = stepName Then
            getSymbol = ws.Cells(i, 2).Value
            Exit Function
        End If
    Next i
    getSymbol = ""
End Function

Function getWorkCenter(stepName As String) As String
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Set ws = Worksheets("Danh Sach Cong Doan")
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    For i = 2 To lastRow
        If ws.Cells(i, 1).Value = stepName Then
            getWorkCenter = ws.Cells(i, 3).Value
            Exit Function
        End If
    Next i
    getWorkCenter = ""
End Function

Function getKho(workCenter As String) As String
    Dim ws As Worksheet
    Dim lastRow As Long
    Dim i As Long
    Set ws = Worksheets("Danh Sach Cong Doan")
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    For i = 2 To lastRow
        If ws.Cells(i, 3).Value = workCenter Then
            getKho = ws.Cells(i, 4).Value
            Exit Function
        End If
    Next i
    getKho = ""
End Function

Sub CreateDropdowns(ByVal newWs As Worksheet, ByVal stepsCount As Integer)
    Dim lastRow As Long
    Dim ws As Worksheet
    
    ' Danh sach Work Center
    Set ws = Worksheets("Danh Sach Work Center")
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    With newWs.Range("K2:K" & stepsCount + 2).Validation
        .Delete
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:= _
        xlBetween, Formula1:="='Danh Sach Work Center'!$A$2:$A$" & lastRow
        .IgnoreBlank = True
        .InCellDropdown = True
        .ShowInput = True
        .ShowError = True
    End With
    
    ' Danh sach Kho xuat
    Set ws = Worksheets("Danh Sach Kho")
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    With newWs.Range("J2:J" & stepsCount + 2).Validation
        .Delete
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:= _
        xlBetween, Formula1:="='Danh Sach Kho'!$A$2:$A$" & lastRow
        .IgnoreBlank = True
        .InCellDropdown = True
        .ShowInput = True
        .ShowError = True
    End With
    
    ' Danh s�ch Kho nhap
    Set ws = Worksheets("Danh Sach Kho")
    lastRow = ws.Cells(ws.Rows.Count, 1).End(xlUp).Row
    With newWs.Range("I2:I" & stepsCount + 2).Validation
        .Delete
        .Add Type:=xlValidateList, AlertStyle:=xlValidAlertStop, Operator:= _
        xlBetween, Formula1:="='Danh Sach Kho'!$A$2:$A$" & lastRow
        .IgnoreBlank = True
        .InCellDropdown = True
        .ShowInput = True
        .ShowError = True
    End With
End Sub



