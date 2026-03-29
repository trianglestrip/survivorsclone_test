@echo off
chcp 65001 >nul
echo ========================================
echo 技能修复测试套件
echo ========================================
echo.

echo [1/3] 测试技能特效...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --headless --script tests/test_skill_effects_visual.gd
if %errorlevel% neq 0 (
    echo 错误：技能特效测试失败
    pause
    exit /b 1
)

echo.
echo [2/3] 测试宗派/武器切换...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --headless --script tests/test_sect_weapon_switch.gd
if %errorlevel% neq 0 (
    echo 错误：切换测试失败
    pause
    exit /b 1
)

echo.
echo [3/3] 测试技能消失机制...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --headless --script tests/test_skill_disappear.gd
if %errorlevel% neq 0 (
    echo 错误：消失机制测试失败
    pause
    exit /b 1
)

echo.
echo ========================================
echo 所有测试通过！
echo ========================================
pause
