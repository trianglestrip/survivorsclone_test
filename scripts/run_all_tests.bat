@echo off
echo ========================================
echo 运行所有自动化测试
echo ========================================
echo.

set GODOT="F:\project\godot\Godot_v4.6.1-stable_win64_console.exe"

echo [1/8] 运行综合系统测试...
%GODOT% --headless --script tests/test_all_systems.gd
echo.

echo [2/8] 运行伤害系统测试...
%GODOT% --headless --script tests/test_damage_system.gd
echo.

echo [3/8] 运行技能系统测试...
%GODOT% --headless --script tests/test_stage2_skills.gd
echo.

echo [4/8] 运行武器系统测试...
%GODOT% --headless --script tests/test_stage3_weapons.gd
echo.

echo [5/8] 运行圣物系统测试...
%GODOT% --headless --script tests/test_stage4_relics.gd
echo.

echo [6/8] 运行敌人系统测试...
%GODOT% --headless --script tests/test_stage5_enemies.gd
echo.

echo [7/8] 运行关卡系统测试...
%GODOT% --headless --script tests/test_stage6_level.gd
echo.

echo [8/8] 运行特效可视化测试...
%GODOT% --headless --script tests/test_skill_effects_visual.gd
echo.

echo ========================================
echo 所有测试完成！
echo ========================================
pause
