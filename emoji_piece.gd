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
	var category = RecipeManager.get_category(emoji_string)
	var base_color = _get_category_color(category)
	
	# Apply Bold Shader
	var shader = load("res://assets/pixel_beautify.gdshader")
	var mat = ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("base_color", base_color)
	mat.set_shader_parameter("bevel_size", 0.12)
	mat.set_shader_parameter("shine_intensity", 0.0)
	
	material = mat
	
	# Bold Drop Shadow (Thicker & Darker)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.6)
	style.set_corner_radius_all(0)
	style.border_width_left = 6
	style.border_width_top = 6
	style.border_width_right = 6
	style.border_width_bottom = 6
	style.border_color = Color(0, 0, 0, 1.0) # Solid black border
	style.expand_margin_left = 2
	style.expand_margin_top = 2
	style.expand_margin_right = 2
	style.expand_margin_bottom = 2
	
	style.shadow_size = 0
	style.shadow_offset = Vector2(8, 8) # Deep shadow
	add_theme_stylebox_override("panel", style)
	
	custom_minimum_size = Vector2(64, 64)
	size = Vector2(64, 64)
	pivot_offset = size / 2.0
	
	if label:
		label.add_theme_font_size_override("font_size", 44)
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
		label.add_theme_constant_override("shadow_offset_x", 3)
		label.add_theme_constant_override("shadow_offset_y", 3)
		label.add_theme_constant_override("shadow_outline_size", 6)

func _get_category_color(cat: String) -> Color:
	# Hyper-Saturated Bold Colors
	match cat:
		"Atmosphere": return Color(0.2, 0.6, 1.0) # Vivid Azure
		"Terrain": return Color(0.8, 0.5, 0.3)    # Bright Terracotta
		"Flora": return Color(0.1, 0.9, 0.3)      # Electric Green
		"Fauna": return Color(1.0, 0.8, 0.0)      # Neon Gold
		"Crafting": return Color(0.7, 0.7, 0.8)   # Solid Steel
		"Tech": return Color(0.8, 0.1, 1.0)       # Cyber Purple
		"Food": return Color(1.0, 0.2, 0.2)       # Punchy Red
		_: return Color(0.6, 0.6, 0.6)             # Bold Gray

func _on_mouse_entered():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_BACK)
	if material is ShaderMaterial:
		tween.tween_property(material, "shader_parameter/shine_intensity", 0.4, 0.2)

func _on_mouse_exited():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK)
	if material is ShaderMaterial:
		tween.tween_property(material, "shader_parameter/shine_intensity", 0.0, 0.3)

func _get_drag_data(at_position: Vector2):
	var preview = preload("res://emoji_piece.tscn").instantiate()
	preview.set_emoji(emoji_string, false)
	preview.modulate.a = 0.8
	preview.rotation = deg_to_rad(randf_range(-10, 10))
	
	var c = Control.new()
	c.add_child(preview)
	preview.position = -preview.size / 2
	set_drag_preview(c)
	
	# Small scale down effect on origin when dragged
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
	
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
