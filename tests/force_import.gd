extends SceneTree

## 强制导入技能纹理

func _init():
	print("开始导入技能纹理...")
	
	var dir = DirAccess.open("res://Textures/Skills/Animations/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var count = 0
		
		while file_name != "":
			if file_name.ends_with(".png"):
				var path = "res://Textures/Skills/Animations/" + file_name
				var texture = load(path)
				if texture:
					count += 1
				else:
					print("  [警告] 无法加载: %s" % file_name)
			file_name = dir.get_next()
		
		print("✓ 成功导入 %d 个纹理文件" % count)
	else:
		print("✗ 无法打开目录")
	
	quit()
