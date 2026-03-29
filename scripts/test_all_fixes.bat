@echo off
chcp 65001 >nul
echo ========================================
echo All Fixes Verification Test Suite
echo ========================================
echo.

echo [1/4] Testing World Input...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --headless --script tests/test_world_input.gd
if %errorlevel% neq 0 (
    echo ERROR: World input test failed
    pause
    exit /b 1
)

echo.
echo [2/4] Testing All Sects Visual Effects...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --headless --script tests/test_all_sects_visual.gd
if %errorlevel% neq 0 (
    echo ERROR: Visual effects test failed
    pause
    exit /b 1
)

echo.
echo [3/4] Testing Interactive Controls...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --headless --script tests/test_interactive_controls.gd
if %errorlevel% neq 0 (
    echo ERROR: Interactive controls test failed
    pause
    exit /b 1
)

echo.
echo [4/4] Testing Full System Integration...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --headless --script tests/test_all_systems.gd
if %errorlevel% neq 0 (
    echo ERROR: System integration test failed
    pause
    exit /b 1
)

echo.
echo ========================================
echo All Tests Passed!
echo ========================================
echo.
echo Fixed Issues:
echo   - Main game key switching (1-0)
echo   - Duplicate variable definitions
echo   - All sects visual effects unified
echo.
pause
