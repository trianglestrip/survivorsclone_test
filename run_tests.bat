@echo off
echo 运行架构重构测试...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --path "f:\project\SurvivorsClone_Test" res://tests/test_architecture_refactor.tscn --quiet --headless
echo.
echo 运行 Effect 系统测试...
"F:\project\godot\Godot_v4.6.1-stable_win64_console.exe" --path "f:\project\SurvivorsClone_Test" res://tests/test_effect_system.tscn --quiet --headless
echo.
echo 测试完成！
pause
