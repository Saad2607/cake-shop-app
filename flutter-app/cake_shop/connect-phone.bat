@echo off
set ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe
if not exist "%ADB%" (
    echo adb not found. Install Android SDK Platform-Tools.
    pause
    exit /b 1
)
echo Connecting phone to backend via USB...
"%ADB%" reverse tcp:3000 tcp:3000
"%ADB%" devices
echo.
echo Done! useUsbConnection should be true in lib/config/api_config.dart
echo Backend must be running: cd backend ^&^& npm run dev
echo Then: flutter run
pause
