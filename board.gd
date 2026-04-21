extends Control

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "emoji":
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant):
	if data["is_inventory"]:
		var new_piece = preload("res://emoji_piece.tscn").instantiate()
		new_piece.set_emoji(data["emoji"], false)
		add_child(new_piece)
		new_piece.position = at_position - Vector2(45, 45)
	else:
		var source = data["source_node"]
		if is_instance_valid(source):
			source.get_parent().remove_child(source)
			add_child(source)
			source.position = at_position - Vector2(45, 45)
