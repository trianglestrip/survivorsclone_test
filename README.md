# SurvivorsClone_Test

这是一个基于 Godot 的生存类克隆游戏项目，已将游戏 UI 文本翻译为中文，并添加了 Git 编码配置以保证中文文件不乱码。

## 项目简介

- 使用 Godot 引擎开发
- 包含玩家、敌人、升级系统和生命/经验 UI
- 已将主要界面文字、升级说明、道具名称等改为中文显示

## 运行方式

1. 使用 Godot 打开本项目目录 `f:\project\SurvivorsClone_Test`。
2. 选择 `project.godot` 项目文件。
3. 运行场景或直接启动主场景。

## 文件说明

- `Player/player.tscn`：玩家场景和界面
- `TitleScreen/menu.tscn`：标题菜单场景
- `Utility/upgrade_db.gd`：升级与道具数据定义
- `Utility/item_option.tscn`：道具选项 UI
- `Utility/basic_button.tscn`：通用按钮模板

## 提交与编码设置

- 添加了 `.gitattributes`，强制文本文件使用 UTF-8 编码并统一换行格式
- 添加了 `.gitignore`，忽略 Godot 编辑器缓存和临时文件

## 已完成

- 修正中文 UI 文本显示
- 修复 `lbl_Result` 节点名错误导致空实例问题
- 提交并推送到远程仓库

## 备注

如果在不同操作系统上打开项目时出现编码或换行问题，请先确保使用 Git 的 `core.autocrlf` 设置为合适值，并已经启用 `.gitattributes`。
