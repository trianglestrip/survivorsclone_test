@echo off
echo ================================================================
echo 暖雪改造 - 第一阶段测试
echo ================================================================
echo.
echo 运行 InputManager 测试...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --path "f:\project\SurvivorsClone_Test" res://tests/test_stage1_input.tscn
echo.
echo ---------------------------------------------------------------
echo 运行攻击系统测试...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --path "f:\project\SurvivorsClone_Test" res://tests/test_stage1_attack.tscn
echo.
echo ---------------------------------------------------------------
echo 运行冲刺系统测试...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --path "f:\project\SurvivorsClone_Test" res://tests/test_stage1_dash.tscn
echo.
echo ================================================================
echo 第一阶段测试完成！
echo ================================================================
pause
