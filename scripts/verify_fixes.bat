@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo.
echo ========================================
echo Fix Verification Script
echo ========================================
echo.

set GODOT_PATH=F:\project\godot\Godot_v4.6.1-stable_win64_console.exe
set TOTAL_TESTS=0
set PASSED_TESTS=0

echo [1/5] Verifying Thunder Strike Range Fix...
"%GODOT_PATH%" --headless --script tests/test_projectile_skills.gd > nul 2>&1
if !errorlevel! equ 0 (
    echo   Status: PASS
    set /a PASSED_TESTS+=1
) else (
    echo   Status: FAIL
)
set /a TOTAL_TESTS+=1

echo.
echo [2/5] Verifying Skill Display...
"%GODOT_PATH%" --headless --script tests/test_skill_display.gd > nul 2>&1
if !errorlevel! equ 0 (
    echo   Status: PASS
    set /a PASSED_TESTS+=1
) else (
    echo   Status: FAIL
)
set /a TOTAL_TESTS+=1

echo.
echo [3/5] Verifying Texture Loading...
"%GODOT_PATH%" --headless --script tests/test_skill_textures.gd > nul 2>&1
if !errorlevel! equ 0 (
    echo   Status: PASS
    set /a PASSED_TESTS+=1
) else (
    echo   Status: FAIL
)
set /a TOTAL_TESTS+=1

echo.
echo [4/5] Verifying World Input...
"%GODOT_PATH%" --headless --script tests/test_world_input.gd > nul 2>&1
if !errorlevel! equ 0 (
    echo   Status: PASS
    set /a PASSED_TESTS+=1
) else (
    echo   Status: FAIL
)
set /a TOTAL_TESTS+=1

echo.
echo [5/5] Verifying Full System...
"%GODOT_PATH%" --headless --script tests/test_all_systems.gd > nul 2>&1
if !errorlevel! equ 0 (
    echo   Status: PASS
    set /a PASSED_TESTS+=1
) else (
    echo   Status: FAIL
)
set /a TOTAL_TESTS+=1

echo.
echo ========================================
echo Verification Complete
echo ========================================
echo.
echo Total Tests: !TOTAL_TESTS!
echo Passed: !PASSED_TESTS!
echo Failed: !TOTAL_TESTS! - !PASSED_TESTS!
echo.

if !PASSED_TESTS! equ !TOTAL_TESTS! (
    echo Result: ALL TESTS PASSED
    echo Status: READY TO DEPLOY
    exit /b 0
) else (
    echo Result: SOME TESTS FAILED
    echo Status: NEEDS ATTENTION
    exit /b 1
)
