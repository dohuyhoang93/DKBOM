@echo off
chcp 65001 >nul
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

call :box "WATCHDOG TRACKING UiPATH PROCESS"

:: === CẤU HÌNH ===
set "LOCK_FILE=%USERPROFILE%\Documents\LogUiPath\STATUS.lock"
set "INPUTJSON=%USERPROFILE%\Documents\LogUiPath\input.json"
set "UIPATH_EXE=%USERPROFILE%\AppData\Local\Programs\UiPath\Studio\UiRobot.exe"
set "PROJECT_PATH_SEARCH=%USERPROFILE%\Documents\*.nupkg"
set "PROJECT_PATH="
set "MAX_RETRY=3"
set /a WAIT_SECONDS=240
set /a WAIT_SECONDS_EXIT_FILE=45
set /a RETRY_COUNT=0
set "PREV_FILETIME="
call :SEARCH_NUPKG

echo [*] Watchdog initial complete

call :section "Watchdog Running ..."

echo [~] Đang khởi chạy tiến trình UiPath lần đầu...
start "run uipath" /b "%UIPATH_EXE%" execute --file "%PROJECT_PATH%"
echo [~] Hoàn thành khởi động tiến trình UiPath
call :done

:: === MAIN VÒNG LẶP WATCHDOG ===
:RETRY_LOOP
echo [~] Watchdog is running
echo [.] Đợi %WAIT_SECONDS_EXIT_FILE% giây để UiPath khởi tạo...

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

:: Đọc dòng đầu tiên của file .lock vào biến STATUS
set /p STATUS=<"%LOCK_FILE%"

:: So sánh và exit nếu nội dung là FINISH
if /i "%STATUS%"=="FINISH" (
    echo [*] Tiến trình UiPath đã hoàn tất.
    call :done
    call :section "Watchdog Exiting"
    pause
    exit
)

call :GET_FILE_MODTIME
echo [+] Thời gian sửa sau: !FILETIME!

if "!FILETIME!"=="!PREV_FILETIME!" (
    echo [*] File không được cập nhật. Xử lý khởi chạy lại UiPath...
    goto :RESTART_UIPATH
)

echo [+] File được cập nhật. Tiến trình đang hoạt động tốt.
set /a RETRY_COUNT=0
goto :RETRY_LOOP


:: === HÀM TÌM FILE NUPKG ===
:SEARCH_NUPKG
REM Kiểm tra xem biến đã được gán đúng chưa
ECHO [~] Search nupkg file in: %PROJECT_PATH_SEARCH%

REM Lặp qua các tệp khớp với mẫu
FOR %%F IN ("%PROJECT_PATH_SEARCH%") DO (
    REM ECHO Found nupkg file: "%%F"
	SET "PROJECT_PATH=%%F"
	echo [.] Found nupkg file: !PROJECT_PATH!
	REM GOTO :EOF khớp với file cuối cùng matching
)

REM Nếu không có tệp nào khớp, vòng lặp FOR sẽ không thực thi gì cả.
IF NOT EXIST "%PROJECT_PATH%" (
    ECHO [.] No .nupkg files starting with DKBOM found in %PROJECT_PATH_SEARCH%
	call :section "Watchdog Stopped"
	pause
	exit
)

echo [*] Set nupkg project file is: %PROJECT_PATH%
GOTO :EOF

:: === HÀM XỬ LÝ KHỞI ĐỘNG LẠI ===
:RESTART_UIPATH
if %RETRY_COUNT% GEQ %MAX_RETRY% (
    echo [*] Đã thử %MAX_RETRY% lần nhưng file lock không cập nhật. Xóa input.json và thoát watchdog.
	echo [.] Đợi %WAIT_SECONDS_EXIT_FILE% giây...
	timeout /t %WAIT_SECONDS_EXIT_FILE% /nobreak >nul
	del %INPUTJSON%
	call :section "Watchdog Stopped"
	pause
    exit
)
set /a RETRY_COUNT+=1
echo [*] Đang thử khởi động lại lần thứ %RETRY_COUNT%...

echo [~] Đóng toàn bộ tiến trình UiPath và Ksystem...
taskkill /f /im UiPath.Studio.exe >nul 2>&1
taskkill /f /im UiPath.Executor.exe >nul 2>&1
taskkill /f /im UiPath.Agent.exe >nul 2>&1
taskkill /f /im Angkor.Ylw.Main.MainWin45.exe >nul 2>&1

echo [~] Đang khởi chạy lại tiến trình UiPath...
start "run uipath" /b "%UIPATH_EXE%" execute --file "%PROJECT_PATH%"
echo [*] Hoàn thành khởi động lại tiến trình UiPath
call :done
goto :RETRY_LOOP

:: === HÀM LẤY THỜI GIAN ===
:GET_FILE_MODTIME
set "FILETIME="
for %%F in ("%LOCK_FILE%") do (
    set "FILETIME=%%~tF"
)
echo [~] Đã kiểm tra thời điểm modify STATUS.lock
goto :EOF

:: === HÀM HIỂN THỊ ===
:section
echo.
echo =======================================================
echo 🔷 %~1
echo =======================================================
echo.
goto :eof

:done
echo.
echo ✔ DONE!
echo -------------------------------------------------------
echo.
goto :eof

:box
setlocal enabledelayedexpansion
set "msg=%~1"

:: Tính độ dài chuỗi gốc
set "str=%msg%"
set /a len=0
:strlen_loop
if defined str (
    set "str=!str:~1!"
    set /a len+=1
    goto strlen_loop
)

:: Cộng thêm 2 ký tự padding (1 mỗi bên)
set /a plen=len + 2

:: Tạo dòng trên
set "top=┌"
for /l %%i in (1,1,%plen%) do set "top=!top!─"
set "top=!top!┐"

:: Tạo dòng giữa, có padding trái và phải
set "mid=│ !msg! │"

:: Tạo dòng dưới
set "bot=└"
for /l %%i in (1,1,%plen%) do set "bot=!bot!─"
set "bot=!bot!┘"

:: In ra
echo !top!
echo !mid!
echo !bot!
endlocal
exit /b