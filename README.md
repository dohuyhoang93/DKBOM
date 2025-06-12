# <span style="color: #39ff14; text-shadow: 0 0 3px #39ff14, 0 0 6px #39ff14, 0 0 10px #39ff14; font-weight: bold;"><strong>HƯỚNG DẪN CÀI ĐẶT</strong></span><br>
## 1. Nhập thông tin đăng nhập Ksystem trong gói file cài đặt:
- Tải về file: `zip` của dự án. Mở UiPath studio và publish dự án sang file `DK.BOM.*.*.*.nupkg`.<br>
- Lưu file `.nupkg` này tại thư mục `Documents` chính *(C:\Users\username\Documents\)*. **Đây là bắt buộc.**
- Mở file `.nupkg` này ra (có thể mở bằng 7zip hoặc bất cứ chương trình giải nén nào).
- Tìm và mở file: `KsystemIdentication.txt`. Đây là file chứa thông tin đăng nhập Ksystem. Nhập thông tin đăng nhập cho user muốn sử dụng. Sau đó `Save` lại.<br>
    >id:user_name_đăng_nhập<br>
    >passwword:mật_khẩu
## 2. Lấy file `Input Data.xlsm` & `Watchdog.bat`
- Tại thư mục đã giải nén, tìm file: `Watchdog.bat`. Copy file này và paste vào thư mục nào bạn thích. Hoặc tạo đường dẫn ***shortcut*** tới file này.<br>
- Bạn cũng cần phải lấy file `Input Data.xlsm` từ trong này ra để sử dụng. Bởi vì, mỗi phiên bản mới của Project UiPath, sẽ đi kèm với thay đổi về input đầu vào trong file `Input data.xlsm` này.<br>
- Kiểm tra đường dẫn tới `UiRobot.exe` có đúng với thực tế trên máy bạn không. Đường dẫn đúng có dạng:<br>*(C:\username\AppData\Local\Programs\UiPath\Studio\UiRobot.exe)* <br>
Nếu không đúng, hãy cập nhật đường dẫn vào `Watchdog.bat` tại dòng:<br>
    >*set "UIPATH_EXE=%USERPROFILE%\AppData\Local\Programs\UiPath\Studio\UiRobot.exe"*


#  Khởi chạy dự án:
## Có 2 cách để chạy dự án.
1. **Chạy trực tiếp dự án trong UiPath studio.**<br>
    - Cách này chỉ có khả năng tự khởi động lại Ksystem sau khi đăng ký 10 mã.***(Tính năng này tạm thời đã bị tắt bỏ)***<br> 
    - Có thể quay lại bước đã dừng trước đó.<br>
2. **Chạy từ `Watchdog.bat`**<br>
    - Có khả năng nhận ra dự án Uipath đang bị dừng do lỗi. Nó sẽ đóng tất cả tiến trình UiPath & Ksystem. Sau đó khởi động và chạy lại từ vị trí bị đăng ký lỗi trước đó. Sau 3 lần thử lại này. `Watchdog` sẽ tự thoát và xóa file `input.json` chứa thông tin về:<br>
        - Lựa chọn các step đăng ký.
        - Vị trí file `Input Data.xlsm`<br>

*Về bản chất, cách này sử dụng `Watchdog` như một chương trình giám sát, mở file `DK.BOM.*.*.*.nupkg` với trình chạy tự động `UiRobot`. Sau đó theo dõi quá trình hoạt động của dự án thông qua file `STATUS.lock`.*

# Sau khi chạy xong
Sau khi dự án chạy xong mà không phát sinh lỗi gì. Nó sẽ xóa các tệp:
`input.json` và `STATUS.lock`.
Tên mã đã đăng ký xong, được lưu trong các file log tại `Document\LogUiPath`:<br>

> DK_ITEM_Log.txt<br>
> DK_BOM_Log.txt<br>
> DK_HTCD_log.txt<br>
> DK_QTSX_Log.txt<br>
> DK_TTLV_Log.txt<br>

UiPath **không cho phép** mở lại dự án và **đăng ký lại** các mã này. Trừ khi bạn **xóa thủ công** tên mã được lưu trong các file log này. Hoặc xóa toàn bộ các file cũng như cả thư mục **LogUiPath**.<br>
___
Dù đã có `Watchdog` giám sát. Nhưng không thể đảm bảo tất cả lỗi sẽ được phát hiện. Một số trường hợp:
- Lỗi input đầu vào từ file `Input data.xlsm`<br>
- Lỗi kết nối internet của Ksystem<br>
- Lỗi logic khi lập trình dự án UiPath<br>

Các lỗi này có thể không gây dừng tiến trình UiPath. `Watchdog` không hề phát hiện ra sự cố. Mặc dù thực tế lỗi đã phát sinh. Vì vậy, tốt hơn cả là chạy dự án với sự giám sát của con người.