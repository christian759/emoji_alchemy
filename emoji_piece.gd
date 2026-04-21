extends PanelContainer

var emoji_string: String = "💧"
var is_inventory_item: bool = false

@onready var label: Label = $Label

func _ready():
	label.text = emoji_string
	_setup_style()
	
	# Pop-in animation
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func set_emoji(emoji: String, inventory: bool = false):
	emoji_string = emoji
	is_inventory_item = inventory
	if label:
		label.text = emoji_string

func _setup_style():
	var style = StyleBoxFlat.new()
	# Glassmorphism: semi-transparent white with a strong border
	style.bg_color = Color(1.0, 1.0, 1.0, 0.15)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1.0, 1.0, 1.0, 0.3)
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_left = 24
	style.corner_radius_bottom_right = 24
	style.shadow_color = Color(0, 0, 0, 0.2)
	style.shadow_size = 15
	add_theme_stylebox_override("panel", style)
	
	custom_minimum_size = Vector2(90, 90)
	size = Vector2(90, 90)
	pivot_offset = size / 2.0

func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.15, 1.15), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	modulate = Color(1.1, 1.1, 1.2) # Subtle glow

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	modulate = Color.WHITE

func _get_drag_data(at_position: Vector2):
	var preview = preload("res://emoji_piece.tscn").instantiate()
	preview.set_emoji(emoji_string, false)
	preview.modulate.a = 0.6
	var c = Control.new()
	c.add_child(preview)
	preview.position = -preview.size / 2
	set_drag_preview(c)
	
	return {"type": "emoji", "emoji": emoji_string, "source_node": self, "is_inventory": is_inventory_item}

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "emoji":
		var dragged_emoji = data["emoji"]
		var source = data["source_node"]
		if source != self and RecipeManager.can_combine(emoji_string, dragged_emoji):
			return true
	return false

func _drop_data(at_position: Vector2, data: Variant):
	var dragged_emoji = data["emoji"]
	var result = RecipeManager.combine(emoji_string, dragged_emoji)
	if result != "":
		# Signal via Global Autoload instead of brittle root access
		RecipeManager.request_merge.emit(result, global_position + size/2.0)
		
		if not data["is_inventory"] and is_instance_valid(data["source_node"]):
			data["source_node"].queue_free()
		queue_free()
