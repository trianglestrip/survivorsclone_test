extends Node

# 性能监控组件 - 记录和显示详细性能数据

var start_time = 0.0
var frame_samples = []
var max_samples = 300  # 记录 5 秒的数据（60 FPS）

var stats = {
	"avg_fps": 0.0,
	"min_fps": 999.0,
	"max_fps": 0.0,
	"frame_time_ms": 0.0,
	"memory_mb": 0.0,
	"object_count": 0
}

func _ready():
	start_time = Time.get_ticks_msec() / 1000.0
	print("\n=== 性能监控启动 ===")

func _process(delta):
	# 记录帧时间
	var fps = 1.0 / delta if delta > 0 else 0
	frame_samples.append(fps)
	
	# 保持样本数量
	if frame_samples.size() > max_samples:
		frame_samples.pop_front()
	
	# 每秒更新统计
	if Engine.get_frames_drawn() % 60 == 0:
		_update_stats()

func _update_stats():
	if frame_samples.is_empty():
		return
	
	# 计算平均 FPS
	var sum_fps = 0.0
	stats["min_fps"] = 999.0
	stats["max_fps"] = 0.0
	
	for fps in frame_samples:
		sum_fps += fps
		if fps < stats["min_fps"]:
			stats["min_fps"] = fps
		if fps > stats["max_fps"]:
			stats["max_fps"] = fps
	
	stats["avg_fps"] = sum_fps / frame_samples.size()
	stats["frame_time_ms"] = 1000.0 / stats["avg_fps"] if stats["avg_fps"] > 0 else 0
	
	# 获取内存使用
	stats["memory_mb"] = Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0
	
	# 获取对象数量
	stats["object_count"] = Performance.get_monitor(Performance.OBJECT_COUNT)

func get_stats() -> Dictionary:
	return stats

func print_summary():
	print("\n=== 性能测试总结 ===")
	print("平均 FPS: %.1f" % stats["avg_fps"])
	print("最低 FPS: %.1f" % stats["min_fps"])
	print("最高 FPS: %.1f" % stats["max_fps"])
	print("平均帧时间: %.2f ms" % stats["frame_time_ms"])
	print("内存使用: %.1f MB" % stats["memory_mb"])
	print("对象数量: %d" % stats["object_count"])
	print("运行时长: %.1f 秒" % ((Time.get_ticks_msec() / 1000.0) - start_time))
	print("===================\n")
