extends Area2D


const END_SCENE_PATH = "res://scenes/end.tscn"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var scene_name = get_tree().current_scene.get_path()
		var path_name = scene_name.get_name(1)
		
		var level_num = path_name.split(" ")
		var current_level = int(level_num[1])
		
		var next_level = current_level + 1
		var next_level_path = "res://scenes/level_"+ str(next_level) +".tscn"
		var target_scene_path: String
		
		# التحقق مما إذا كان ملف المستوى التالي موجودًا
		if ResourceLoader.exists(next_level_path):
			# المستوى التالي موجود، انتقل إليه
			target_scene_path = next_level_path
			print("Loading next level: ", target_scene_path)
		else:
			# المستوى التالي غير موجود، انتقل إلى مشهد النهاية
			target_scene_path = END_SCENE_PATH
			print("All levels completed! Loading end scene: ", target_scene_path)
		
		# 4. تنفيذ تغيير المشهد
		var error_code = get_tree().change_scene_to_file(target_scene_path)
		
		# 5. التحقق من نجاح العملية
		if error_code != OK:
			print("FATAL ERROR: Failed to load scene: ", target_scene_path)
