extends SceneTree

## 清除Godot缓存辅助脚本
## 用于解决资源不刷新的问题

func _init():
	print("\n" + "=".repeat(60))
	print("清除Godot资源缓存")
	print("=".repeat(60) + "\n")
	
	await create_timer(0.1).timeout
	
	var cache_paths = [
		".godot/imported/",
		".godot/editor/",
		".godot/shader_cache/"
	]
	
	var cleared_count = 0
	
	for path in cache_paths:
		if DirAccess.dir_exists_absolute(path):
			print("正在清除: %s" % path)
			var result = _remove_directory_recursive(path)
			if result:
				print("  ✓ 已清除")
				cleared_count += 1
			else:
				print("  ✗ 清除失败")
		else:
			print("路径不存在: %s" % path)
	
	print("\n" + "=".repeat(60))
	if cleared_count > 0:
		print("✓ 已清除 %d 个缓存目录" % cleared_count)
		print("\n请重启Godot编辑器以应用更改")
	else:
		print("✗ 未清除任何缓存")
	print("=".repeat(60) + "\n")
	
	quit(0)

func _remove_directory_recursive(path: String) -> bool:
	var dir = DirAccess.open(path)
	if not dir:
		return false
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path = path + "/" + file_name
			
			if dir.current_is_dir():
				_remove_directory_recursive(full_path)
			else:
				DirAccess.remove_absolute(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	return DirAccess.remove_absolute(path) == OK
