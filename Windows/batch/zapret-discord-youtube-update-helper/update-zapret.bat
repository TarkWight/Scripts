@echo off
setlocal EnableDelayedExpansion
chcp 65001

:: ================================================
:: 1. Запрос прав администратора (если не запущен от администратора)
:: ================================================
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Запрос прав администратора
    goto UACPrompt
) else (
    goto gotAdmin
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

:: ================================================
:: 2. Остановка и удаление старого драйвера Windivert
:: ================================================
echo Остановка и удаление Windivert...
sc stop windivert >nul 2>&1
sc delete windivert >nul 2>&1

:: ================================================
:: 3. УКАЖИТЕ СВОЙ ПУТЬ К ПАПКЕ zdy
:: ================================================
set "ZDY_PATH=C:\Путь\К\Твоей\Папке\zdy"     ::  измените эту строку

if not exist "%ZDY_PATH%" (
    echo Папка %ZDY_PATH% не найдена
    pause
    exit /b
)

:: ================================================
:: 4. Очистка папки zdy
:: ================================================
echo Очистка папки zdy
rd /s /q "%ZDY_PATH%" 2>nul
md "%ZDY_PATH%"

:: ================================================
:: 5. Поиск самого нового архива zapret-discord-youtube-*.rar в Загрузках
:: ================================================
set "DOWNLOADS=%USERPROFILE%\Downloads"
set "ARCHIVE="

for /f "delims=" %%F in ('dir /b /o:-d "%DOWNLOADS%\zapret-discord-youtube-*.rar" 2^>nul') do (
    set "ARCHIVE=%DOWNLOADS%\%%F"
    goto :archiveFound
)

:archiveFound
if not defined ARCHIVE (
    echo Архив zapret-discord-youtube-*.rar не найден в папке Загрузки
    pause
    exit /b
)

echo Найден архив: %ARCHIVE%
echo Начинаю распаковку...

:: ================================================
:: 6. Распаковка архива в zdy (нужен 7-Zip)
:: ================================================
set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"

if not exist "%SEVENZIP%" (
    set "SEVENZIP=C:\Program Files (x86)\7-Zip\7z.exe"
)
if not exist "%SEVENZIP%" (
    echo 7-Zip не найден! Установи 7-Zip и попробуй снова.
    pause
    exit /b
)

echo Распаковка архива...
"%SEVENZIP%" x "%ARCHIVE%" -o"%ZDY_PATH%" -y >nul

:: ================================================
:: 7. Добавляем содержимое general-upd.txt в list-general.txt
:: ================================================
set "UPD_FILE=%~dp0general-upd.txt"
set "LIST_FILE=%ZDY_PATH%\lists\list-general.txt"

if not exist "%UPD_FILE%" (
    echo Файл general-upd.txt рядом со скриптом не найден
    pause
    exit /b
)

if not exist "%ZDY_PATH%\lists" md "%ZDY_PATH%\lists"

echo Добавление обновлений в list-general.txt
type "%UPD_FILE%" >> "%LIST_FILE%"

echo.
echo ========================================
echo Обновление завершено успешно
echo ========================================
pause