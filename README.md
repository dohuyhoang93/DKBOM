#  Hướng dẫn cài đặt ban đầu
## 1. Nhập thông tin đăng nhập Ksystem trong gói nupkg:
- Tải về file: `zip` của dự án. Giải nén ra. Mở UiPath studio và thêm dự án vào. Sau đó publish dự án sang file `DK.BOM.1.*.*.nupkg`.<br>
- Lưu file `.nupkg` này tại thư mục **`Documents`** chính *(C:\Users\username\Documents\)*. **Đây là bắt buộc.**
- Mở file `.nupkg` này ra (có thể mở bằng 7zip hoặc bất cứ chương trình giải nén nào).
- Tìm và mở file: `KsystemIdentication.txt`. Đây là file chứa thông tin đăng nhập Ksystem.<br>
Nhập thông tin đăng nhập cho user muốn sử dụng (không được có dấu cách `space`). Sau đó `Save` lại.<br>
    >*id:user_name*<br>
    >*password:mật_khẩu*
## 2. Lấy file `Input Data.xlsm` & `Watchdog.bat`
- Vẫn tại thư mục chính trong file `.nupkg`. Tìm file: `Watchdog.bat`. Copy file này và paste vào thư mục ***Documents*** (cùng vị trí với file `nupkg`).<br>
Nếu chương trình giải nén của bạn không cho phép copy trực tiếp. Hãy quay lại thư mục giải nén từ file `zip` ra để lấy file `Watchdog.bat`.<br>
- Bạn cũng cần phải lấy file `Input Data.xlsm` từ trong này ra để sử dụng.<br>
Vì mỗi phiên bản phát hành của dự án đi cùng với thay đổi tính năng trong VBA của file exel này.

- Kiểm tra đường dẫn tới `UiRobot` có đúng không. Đường dẫn đúng có dạng:<br>
*(C:\username\AppData\Local\Programs\UiPath\Studio\UiRobot.exe)* <br>
Nếu không đúng, hãy cập nhật đường dẫn được cài trên máy bạn vào `Watchdog.bat` tại dòng:<br>
*"UIPATH_EXE=%USERPROFILE%*

#  Khởi chạy dự án:
## Có 2 cách để chạy dự án.
1. **Chạy trực tiếp dự án qua Debug trong UiPath studio.**<br>
    - Cách này chỉ có khả năng tự khởi động lại Ksystem sau khi mỗi bước đăng ký được 10 mã.<br>
    - Có thể quay lại bước đã dừng trước đó.<br>
2. **Chạy từ `Watchdog.bat`**<br>
    - Có khả năng nhận ra dự án Uipath đang bị dừng do lỗi. Nó sẽ đóng tất cả tiến trình UiPath & Ksystem. Sau đó khởi động và chạy lại từ vị trí bị đăng ký lỗi trước đó. Sau 3 lần thử lại này. `Watchdog` sẽ tự thoát và xóa file `input.json` chứa thông tin về:<br>
        - Lựa chọn các step đăng ký.
        - Vị trí file `Input Data.xlsm`<br>

*Về bản chất, cách này sử dụng `Watchdog` như một chương trình giám sát. Nó mở file `DK.BOM.1.*.*.nupkg` với trình chạy tự động `UiRobot`. Sau đó theo dõi quá trình hoạt động của dự án thông qua file `STATUS.lock`.*

# Sau khi chạy xong
Sau khi dự án chạy xong mà không phát sinh lỗi gì. UiPath sẽ xóa các tệp:
`input.json` và `STATUS.lock` tại `Document\LogUiPath`.
Các mã đã đăng ký xong sẽ được lưu tại các file log trong `Document\LogUiPath`:<br>
> DK_ITEM_Log.txt<br>
> DK_BOM_Log.txt<br>
> DK_HTCD_log.txt<br>
> DK_QTSX_Log.txt<br>
> DK_TTLV_Log.txt<br>

Từ đây, dù cố tình mở lại dự án và cho *đăng ký lại* các mã này, UiPath cũng **không cho phép**. Trừ khi bạn **xóa thủ công** tên mã được lưu trong các file log này. Hoặc xóa toàn bộ các file cũng như cả thư mục `LogUiPath`.

### Lưu ý:
Dù có Watchdog giám sát. Không có gì đảm bảo 100% Watchdog có thể phát hiện mọi trường hợp lỗi của dự án UiPath. Đôi khi, một số lỗi: *logic, dữ liệu đầu vào, kết nối với Ksystem bị gián đoạn* khiến các thao tác trên UiPath vẫn ghi nhận thành công. Mặc dù thực tế đã xảy ra lỗi.