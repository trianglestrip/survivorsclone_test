@echo off
echo ========================================
echo 清除Godot缓存
echo ========================================
echo.

if exist ".godot\imported" (
    echo 正在删除 .godot\imported...
    rmdir /s /q ".godot\imported"
    echo   完成
) else (
    echo   .godot\imported 不存在
)

if exist ".godot\editor" (
    echo 正在删除 .godot\editor...
    rmdir /s /q ".godot\editor"
    echo   完成
) else (
    echo   .godot\editor 不存在
)

if exist ".godot\shader_cache" (
    echo 正在删除 .godot\shader_cache...
    rmdir /s /q ".godot\shader_cache"
    echo   完成
) else (
    echo   .godot\shader_cache 不存在
)

echo.
echo ========================================
echo 缓存清除完成！
echo 请重启Godot编辑器以应用更改
echo ========================================
pause
