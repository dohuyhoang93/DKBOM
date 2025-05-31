@echo off
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

:: === CẤU HÌNH ===
set "SCRIPT_DIR=%~dp0"

set "UIPATH_EXE=%USERPROFILE%\AppData\Local\Programs\UiPath\Studio\UiRobot.exe"
set "PROJECT_PATH=%USERPROFILE%\Documents\DK.BOM.1.7.6.nupkg"

set "MAX_RETRY=3"
set /a WAIT_SECONDS=60
set /a WAIT_SECONDS_EXIT_FILE=30

echo [~] Đang khởi chạy tiến trình UiPath lần đầu tiên...
start "run uipath" /b "%UIPATH_EXE%" execute --file "%PROJECT_PATH%"
echo [~] Đã khởi chạy tiến trình UiPath lần đầu tiên...

set "RESTART_COUNTER_FILE=%USERPROFILE%\Documents\LogUiPath\RestartCounter.txt"
set "LOCK_FILE=%USERPROFILE%\Documents\LogUiPath\STATUS.lock"
echo ==== Kết quả đường dẫn các file cần thiết===
echo %RESTART_COUNTER_FILE%
echo %LOCK_FILE%

:: === THIẾT LẬP FILE ĐẾM SỐ LẦN RESTART ===

if not exist "%RESTART_COUNTER_FILE%" (
    echo 0 > "%RESTART_COUNTER_FILE%"
)

:: === MAIN VÒNG LẶP WATCHDOG ===
set "PREV_FILETIME="
echo [*] Watchdog initial complete

:RETRY_LOOP
echo [*] Watchdog is running in loop

:: Đọc số lần restart từ file
set /p RETRY_COUNT=<"%RESTART_COUNTER_FILE%"
if "%RETRY_COUNT%"=="" set RETRY_COUNT=0

if %RETRY_COUNT% GEQ %MAX_RETRY% (
    echo [*] Đã thử %MAX_RETRY% lần nhưng file lock không cập nhật. Thoát watchdog.
	echo 0 > "%RESTART_COUNTER_FILE%"
	pause
    goto :EOF
)

echo [.] Đợi %WAIT_SECONDS_EXIT_FILE% giây...
timeout /t %WAIT_SECONDS_EXIT_FILE% /nobreak >nul

echo [.] Đang kiểm tra file: %LOCK_FILE%
if not exist "%LOCK_FILE%" (
    echo [*] File lock không tồn tại. Xử lý khởi chạy lại UiPath...
    goto :RESTART_UIPATH
)

call :GET_FILE_MODTIME
set "PREV_FILETIME=!FILETIME!"
echo [+] Thời gian sửa trước: !PREV_FILETIME!

echo [.] Đợi %WAIT_SECONDS% giây...
timeout /t %WAIT_SECONDS% /nobreak >nul

if not exist "%LOCK_FILE%" (
    echo [*] File lock đã bị xóa. Khởi động lại UiPath...
    goto :RESTART_UIPATH
)

call :GET_FILE_MODTIME
echo [+] Thời gian sửa sau: !FILETIME!

if "!FILETIME!"=="!PREV_FILETIME!" (
    echo [*] File không được cập nhật. Xử lý khởi chạy lại UiPath...
    goto :RESTART_UIPATH
)

echo [+] File được cập nhật. Tiến trình đang hoạt động tốt.
goto :RETRY_LOOP

:: === HÀM XỬ LÝ KHỞI ĐỘNG LẠI ===
:RESTART_UIPATH
set /a RETRY_COUNT+=1
echo !RETRY_COUNT! > "%RESTART_COUNTER_FILE%"
echo [*] Đang thử khởi động lại lần thứ %RETRY_COUNT%...

echo [~] Đóng toàn bộ tiến trình UiPath và Ksystem...
taskkill /f /im UiPath.Studio.exe >nul 2>&1
taskkill /f /im UiPath.Executor.exe >nul 2>&1
taskkill /f /im UiPath.Agent.exe >nul 2>&1
taskkill /f /im Angkor.Ylw.Main.MainWin45.exe >nul 2>&1

echo [~] Đang khởi chạy lại tiến trình UiPath...
start "run uipath" /b "%UIPATH_EXE%" execute --file "%PROJECT_PATH%"
echo [~] Hoàn thành khởi động lại tiến trình UiPath
echo =======================================================
goto :EOF

:: === HÀM LẤY THỜI GIAN MODIFY FILE ===
:GET_FILE_MODTIME
set "FILETIME="
for %%F in ("%LOCK_FILE%") do (
    set "FILETIME=%%~tF"
)
echo [~] Đã kiểm tra thời điểm modify STATUS.lock
goto :EOF
