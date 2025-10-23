extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var scene_name = get_tree().current_scene.get_path()
		var path_name = scene_name.get_name(1)
		print (path_name)
		
		var level_num = path_name.split(" ")
		var current_level = int(level_num[1])
		print(current_level)
		
		var next_level = current_level + 1
		var next_level_path = get_tree().change_scene_to_file("res://scenes/level_"+ str(next_level) +".tscn")
		print(next_level_path)
		next_level_path
