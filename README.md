# <span style="color: #39ff14; text-shadow: 0 0 3px #39ff14, 0 0 6px #39ff14, 0 0 10px #39ff14; font-weight: bold;"><strong>INSTALLATION GUIDE</strong></span><br>
## 1. Enter Ksystem login information:
- Download the project’s `zip` file and extract it, or use `git clone` to get the project onto your computer.
- Locate and open the file: `KsystemIdentication.txt`. This file contains login credentials for Ksystem. Enter the login details for the user you want to use, then `Save` the file.<br>
    >id:user_login_name<br>
    >password:your_password
- Open UiPath Studio and publish the project as a file named `DK.BOM.*.*.*.nupkg`.<br>
- Save this `.nupkg` file in your main `Documents` folder *(C:\Users\username\Documents\)*. **This is mandatory.**
- If you downloaded the `.nupkg` file directly, open it (using 7zip or any archive program), find and modify the `KsystemIdentication.txt` file as mentioned above.

## 2. Get the `Input Data.xlsm` file
- Inside the extracted folder, locate the file `Input data.xlsm`. This file provides the input data for the UiPath BOM Registration project. Each new version of the BOM Registration project may come with changes in the structure or content of this input file.<br>

## 3. Get the `WatchdogUiPath.exe` file
- Also in the extracted folder, locate the file `WatchdogUiPath.exe`. You may create a shortcut to this file on your Desktop if you wish.
>WatchdogUiPath.exe is an auxiliary program used to run the BOM Registration project in UiPath and monitor its execution.
- Double-click to run `WatchdogUiPath.exe`.
- In the `UiRobot.exe` section, click `Browse` and specify the path to UiPath’s `UiRobot.exe`. This path typically looks like:<br>
*(C:\username\AppData\Local\Programs\UiPath\Studio\UiRobot.exe)*<br>
- In the `NUPKG Folder` section, click `Browse` and select the `Documents` folder or any folder that contains the `.nupkg` file.<br>
>This configuration is saved in a JSON file for future runs. You won’t need to enter it again.<br>
*A batch version of Watchdog is also included in the downloaded folder. It provides similar functionality, but the `.nupkg` file must be placed in the Documents folder: `%USERPROFILE%\Documents`*<br>

# Launching the Project:
### There are two ways to run the project:
1. **Run the project directly in UiPath Studio.**<br>
    - You can resume from the step where it was previously stopped.<br>
    However, it cannot automatically restart the process in case of an error.<br>
2. **Run from `WatchdogUiPath.exe`**<br>
    - It can detect if the UiPath project has stopped due to an error. It will terminate all UiPath & Ksystem processes, then restart and resume from the point of failure. After 3 retry attempts, `Watchdog` will automatically exit and delete the `input.json` file that contains:<br>
        - The selected registration steps<br>
        - The path to the `Input Data.xlsm` file<br>

# After Execution
If the project completes successfully with no errors, it will delete the following files:
`input.json` and `STATUS.lock`.<br>
The names of the completed registrations are saved in log files located at `Document\LogUiPath`:<br>

> DK_ITEM_Log.txt<br>
> DK_BOM_Log.txt<br>
> DK_HTCD_log.txt<br>
> DK_QTSX_Log.txt<br>
> DK_TTLV_Log.txt<br>

UiPath **does not allow** reopening the project to **register these codes again**, unless you **manually delete** the names stored in these log files or remove the entire **LogUiPath** folder.<br>
___
Even though the `Watchdog` supervises the process, it **cannot detect all types of errors**. Some examples include:
- Invalid input data from the `Input data.xlsm` file<br>
- Ksystem internet connectivity issues<br>
- Logic errors in the UiPath project<br>

These types of issues may not stop the UiPath process, and as a result, `Watchdog` cannot detect them — even though the errors occurred.<br>
Therefore, it is recommended to run the project under human supervision.<br>

---

# <span style="color: #39ff14; text-shadow: 0 0 3px #39ff14, 0 0 6px #39ff14, 0 0 10px #39ff14; font-weight: bold;"><strong>HƯỚNG DẪN CÀI ĐẶT</strong></span><br>
## 1. Nhập thông tin đăng nhập Ksystem:
- Tải về file: `zip` của dự án. Sau đó giải nén ra. Hoặc `git clone` dự án về máy tính của bạn.
- Tìm và mở file: `KsystemIdentication.txt`. Đây là file chứa thông tin đăng nhập Ksystem. Nhập thông tin đăng nhập cho user muốn sử dụng. Sau đó `Save` lại.<br>
    >id:user_name_đăng_nhập<br>
    >password:mật_khẩu
- Mở UiPath studio và publish dự án sang file `DK.BOM.*.*.*.nupkg`.<br>
- Lưu file `.nupkg` này tại thư mục `Documents` chính *(C:\Users\username\Documents\)*. **Đây là bắt buộc.**
- Nếu bạn tải trực tiếp file `.nupkg` về. Mở file `.nupkg` này ra (có thể mở bằng 7zip hoặc bất cứ chương trình giải nén nào). Tìm và sửa file `KsystemIdentication.txt` như trên.
## 2. Lấy file `Input Data.xlsm`
- Tại thư mục đã giải nén, tìm file: `Input data.xlsm`. Đây là file sử dụng để cung cấp data đầu vào cho dự án UiPath đăng ký BOM. Mỗi phiên bản mới của dự án UiPath Đăng ký BOM, sẽ đi kèm với thay đổi về input đầu vào trong file `Input data.xlsm` này.<br>

## 3. Lấy file `WatchdogUiPath.exe`
- Cũng trong thư mục đã giải nén. Tìm file `WatchdogUiPath.exe`. Tạo shortcut của file này ra Desktop nếu bạn muốn.
>WatchdogUiPath.exe là một chương trình phụ, dùng để chạy dự án UiPath Đăng ký BOM, đồng thời giám sát quá trình chạy.
- Click đúp để chạy `WatchdogUiPath.exe`.
- Tại mục `UiRobot.exe`, nhấn `Browse` để nhập đường dẫn tới file `UiRobot.exe` của UiPath. Đường dẫn thông thường có dạng:<br>
*(C:\username\AppData\Local\Programs\UiPath\Studio\UiRobot.exe)* <br>
- Tại mục `NUPKG Folder`, nhấn `Browse` để nhập thư mục Documents hoặc bất cứ thư mục nào đang chứa file `.nupkg`.<br>
>Các thông tin này dược lưu vào JSON cho lần chạy sau. Không cần khai báo lại.<br>
*Một phiên bản batch của Watchdog cũng được đính kèm trong thư mục chính đã tải về, cung cấp chức năng tương đương. Nhưng file `.nupkg` phải được để trong thư mục Documents: `%USERPROFILE%\Documents`*<br>
#  Khởi chạy dự án:
### Có 2 cách để chạy dự án.
1. **Chạy trực tiếp dự án trong UiPath studio.**<br>
    - Có thể quay lại bước đã dừng trước đó.<br>
    Nhưng không thể tự khởi động lại tiến trình khi có lỗi.<br>
2. **Chạy từ `WatchdogUiPath.exe`**<br>
    - Có khả năng nhận ra dự án Uipath đang bị dừng do lỗi. Nó sẽ đóng tất cả tiến trình UiPath & Ksystem. Sau đó khởi động và chạy lại từ vị trí bị đăng ký lỗi trước đó. Sau 3 lần thử lại này. `Watchdog` sẽ tự thoát và xóa file `input.json` chứa thông tin về:<br>
        - Lựa chọn các step đăng ký.<br>
        - Vị trí file `Input Data.xlsm`<br>
# Sau khi chạy xong
Sau khi dự án chạy xong mà không phát sinh lỗi gì. Nó sẽ xóa các tệp:
`input.json` và `STATUS.lock`.<br>
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

Các lỗi này có thể không gây dừng tiến trình UiPath. `Watchdog` không hề phát hiện ra sự cố. Mặc dù thực tế lỗi đã phát sinh.<br>
Vì vậy, tốt hơn cả là chạy dự án với sự giám sát của con người.<br>