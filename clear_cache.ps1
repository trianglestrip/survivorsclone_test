# 清除Godot缓存脚本
# 用于解决资源不刷新的问题

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "清除Godot缓存" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$cachePaths = @(
    ".godot\imported",
    ".godot\editor",
    ".godot\shader_cache"
)

$clearedCount = 0

foreach ($path in $cachePaths) {
    if (Test-Path $path) {
        Write-Host "正在删除 $path..." -ForegroundColor Yellow
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        if (-not (Test-Path $path)) {
            Write-Host "  ✓ 完成" -ForegroundColor Green
            $clearedCount++
        } else {
            Write-Host "  ✗ 删除失败" -ForegroundColor Red
        }
    } else {
        Write-Host "$path 不存在" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($clearedCount -gt 0) {
    Write-Host "✓ 已清除 $clearedCount 个缓存目录" -ForegroundColor Green
    Write-Host ""
    Write-Host "请重启Godot编辑器以应用更改" -ForegroundColor Yellow
} else {
    Write-Host "✗ 未清除任何缓存" -ForegroundColor Red
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 可选：自动重启Godot（取消注释以启用）
# $godotPath = "F:\project\godot\Godot_v4.6.1-stable_win64.exe"
# if (Test-Path $godotPath) {
#     Write-Host "正在启动Godot..." -ForegroundColor Yellow
#     Start-Process $godotPath -ArgumentList "--path", (Get-Location).Path
# }

Read-Host "按回车键退出"
