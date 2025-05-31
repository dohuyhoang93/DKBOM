' Đảm bảo bạn đã định nghĩa các arguments trong Invoke Code activity:
' in_FilePath As String
' out_ProcessedSheetsArray As String()
' out_CurrentSheetName As String
' out_CurrentRowNumber As Int32
' out_ErrorMessage As String (Tùy chọn)
' line_Length As Int32

' Khởi tạo giá trị mặc định cho các output
out_ProcessedSheetsArray = New String() {}
out_CurrentSheetName = String.Empty
out_CurrentRowNumber = 0
line_Length = 0

out_ErrorMessage = String.Empty ' reset bắt buộc mỗi vòng xử lý mới
Try
    ' Kiểm tra file có tồn tại không
    If Not System.IO.File.Exists(in_FilePath) Then
        out_ErrorMessage += "Lỗi: File không tồn tại tại đường dẫn: " & in_FilePath
        Return ' Thoát sớm nếu file không tồn tại
    End If

    ' Đọc tất cả các dòng từ file
    Dim lines As String() = System.IO.File.ReadAllLines(in_FilePath)
	line_Length = lines.Length
	

    ' Xử lý dòng 0: Các sheet đã xử lý
    If lines.Length >= 1 AndAlso Not String.IsNullOrWhiteSpace(lines(0)) Then
        ' Tách chuỗi bằng dấu phẩy, sau đó Trim từng phần tử
        out_ProcessedSheetsArray = lines(0).Split(","c).Select(Function(s) s.Trim()).ToArray()
    Else
        out_ErrorMessage += "Cảnh báo: Không có dòng đầu tiên hoặc dòng đầu tiên trống để xử lý các sheet đã hoàn thành. " & vbCrLf
    End If

    ' Xử lý dòng 1: Sheet và hàng đang xử lý
    If lines.Length >= 2 AndAlso Not String.IsNullOrWhiteSpace(lines(1)) Then
        Dim partsLine1 As String() = lines(1).Split(","c).Select(Function(s) s.Trim()).ToArray()
        If partsLine1.Length = 2 Then
            out_CurrentSheetName = partsLine1(0)
            Dim tempRowNumber As Integer
            If Integer.TryParse(partsLine1(1), tempRowNumber) Then
                out_CurrentRowNumber = tempRowNumber
            Else
                out_ErrorMessage += "Lỗi: Hàng đang xử lý ('" & partsLine1(1) & "') ở dòng thứ hai không phải là số nguyên hợp lệ. " & vbCrLf
                ' Quyết định xem có nên reset out_CurrentSheetName không nếu hàng không hợp lệ
                ' out_CurrentSheetName = String.Empty
            End If
        Else
            out_ErrorMessage += "Lỗi: Dòng thứ hai không có định dạng 'SheetName,RowNumber'. " &vbCrLf
        End If
    Else
        out_ErrorMessage += "Cảnh báo: Không có dòng thứ hai hoặc dòng thứ hai trống để xử lý thông tin sheet/hàng hiện tại. " &vbCRLf
    End If

Catch ex As Exception
    
    out_ErrorMessage += "Lỗi hệ thống trong Invoke Code: " & ex.Message & vbCrLf & ex.StackTrace
    ' Đảm bảo các biến output có giá trị mặc định trong trường hợp lỗi nghiêm trọng
    out_ProcessedSheetsArray = New String() {}
    out_CurrentSheetName = String.Empty
    out_CurrentRowNumber = 0
	Throw
End Try