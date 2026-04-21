extends Control

@onready var inventory_box = %InventoryBox
@onready var board_area = $Screens/GameScreen/BoardArea
@onready var keyboard_alchemy = %KeyboardAlchemy
@onready var category_tabs = %CategoryTabs
@onready var game_status = %GameStatus
@onready var timer = $Timer
@onready var inventory_panel = %InventoryPanel
@onready var inventory_toggle = %InventoryToggle
@onready var clear_board_btn = %ClearBoard
@onready var background = $Background

@onready var title_screen = %TitleScreen
@onready var settings_screen = %SettingsScreen
@onready var game_screen = %GameScreen

enum GameMode { SANDBOX, BLITZ, TARGET }
enum GameState { MENU, SETTINGS, GAME }

var current_mode = GameMode.SANDBOX
var current_state = GameState.MENU
var search_query: String = ""
var selected_category: String = "All"
var target_emoji: String = ""
var blitz_discoveries: int = 0
var is_inventory_open: bool = true

var emoji_names: Dictionary = {
	"fire": "🔥", "water": "💧", "earth": "🌍", "wind": "💨",
	"lava": "🌋", "steam": "💨", "seed": "🌱", "tree": "🌳",
	"wave": "🌊", "sun": "☀️", "mountain": "⛰️", "storm": "⛈️",
	"rainbow": "🌈", "diamond": "💎", "gold": "💰", "life": "🌱",
	"tornado": "🌪️", "cloud": "☁️", "rain": "🌧️", "lightning": "🌩️",
	"flower": "🌸", "bear": "🐻", "fish": "🐟", "eagle": "🦅",
	"hammer": "⚒️", "sword": "🗡️", "computer": "💻", "egg": "🍳",
	"apple": "🍎", "volcano": "🌋", "ocean": "🌊", "moon": "🌙",
	"star": "⭐", "rocket": "🚀", "robot": "🤖", "ghost": "👻",
	"alien": "👽", "heart": "❤️", "pizza": "🍕", "beer": "🍺",
	"wine": "🍷", "coffee": "☕", "bread": "🍞", "cheese": "🧀",
	"milk": "🥛", "ice": "🧊", "snow": "❄️",
	"music": "🎶", "car": "🚗", "plane": "✈️", "ship": "🚢",
	"house": "🏠", "city": "🏙️", "night": "🌃", "day": "🌅"
}

func _ready():
	_setup_styles()
	_setup_ui()
	_populate_inventory()
	
	# Core Logic Signals
	RecipeManager.sequence_discovered.connect(_on_sequence_discovered)
	RecipeManager.request_merge.connect(handle_merge)
	keyboard_alchemy.text_submitted.connect(_on_keyboard_alchemy_submitted)
	keyboard_alchemy.text_changed.connect(_on_search_text_changed)
	category_tabs.tab_changed.connect(_on_category_tab_changed)
	timer.timeout.connect(_on_timer_timeout)
	
	# Menu/UI Signals
	inventory_toggle.pressed.connect(_toggle_inventory)
	clear_board_btn.pressed.connect(_clear_board)
	%BtnExitGame.pressed.connect(func(): _switch_state(GameState.MENU))
	%BtnSettings.pressed.connect(func(): _switch_state(GameState.SETTINGS))
	%BtnBack.pressed.connect(func(): _switch_state(GameState.MENU))
	
	%BtnSandbox.pressed.connect(func(): _start_game(GameMode.SANDBOX))
	%BtnBlitz.pressed.connect(func(): _start_game(GameMode.BLITZ))
	%BtnTarget.pressed.connect(func(): _start_game(GameMode.TARGET))
	
	get_viewport().size_changed.connect(_on_viewport_resized)
	_switch_state(GameState.MENU)
	_on_viewport_resized()

func _setup_styles():
	# Background Shader
	var shader = load("res://assets/alchemy_background.gdshader")
	var mat = ShaderMaterial.new()
	mat.shader = shader
	background.material = mat
	
	# Bold Retro Box (6px borders, 8px shadows)
	var bold_panel = StyleBoxFlat.new()
	bold_panel.bg_color = Color(0.1, 0.1, 0.15, 0.98)
	bold_panel.border_width_left = 6
	bold_panel.border_width_top = 6
	bold_panel.border_width_right = 6
	bold_panel.border_width_bottom = 6
	bold_panel.border_color = Color(0, 0, 0, 1.0)
	bold_panel.expand_margin_left = 4
	bold_panel.expand_margin_top = 4
	bold_panel.expand_margin_right = 4
	bold_panel.expand_margin_bottom = 4
	bold_panel.shadow_color = Color(0, 0, 0, 0.7)
	bold_panel.shadow_offset = Vector2(8, 8)
	
	# Apply to panels
	$Screens/SettingsScreen/Panel.add_theme_stylebox_override("panel", bold_panel)
	$Screens/GameScreen/UI/FloatingHeader/Panel.add_theme_stylebox_override("panel", bold_panel)
	inventory_panel.add_theme_stylebox_override("panel", bold_panel)
	
	# Apply to all buttons
	_apply_bold_button_style(%BtnSandbox)
	_apply_bold_button_style(%BtnBlitz)
	_apply_bold_button_style(%BtnTarget)
	_apply_bold_button_style(%BtnSettings)
	_apply_bold_button_style(%BtnBack)
	_apply_bold_button_style(%BtnExitGame)
	_apply_bold_button_style(%InventoryToggle)
	_apply_bold_button_style(%ClearBoard)
	
	# Apply to LineEdit and Tabs
	_apply_bold_input_style(keyboard_alchemy)
	category_tabs.add_theme_stylebox_override("tab_selected", bold_panel)

func _apply_bold_button_style(btn: Button):
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.2, 0.2, 0.3)
	normal.border_width_left = 4
	normal.border_width_top = 4
	normal.border_width_right = 4
	normal.border_width_bottom = 4
	normal.border_color = Color(0, 0, 0, 1.0)
	normal.shadow_offset = Vector2(6, 6)
	normal.shadow_color = Color(0, 0, 0, 0.5)
	
	var hover = normal.duplicate()
	hover.bg_color = Color(0.3, 0.3, 0.45)
	
	var pressed = normal.duplicate()
	pressed.bg_color = Color(0.1, 0.1, 0.2)
	pressed.shadow_offset = Vector2(2, 2) # Physical "press down" effect
	
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_shadow_color", Color.BLACK)
	btn.add_theme_constant_override("shadow_offset_x", 2)
	btn.add_theme_constant_override("shadow_offset_y", 2)

func _apply_bold_input_style(input: LineEdit):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 1.0)
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.border_color = Color(0.5, 0.5, 0.7, 1.0)
	input.add_theme_stylebox_override("normal", style)
	input.add_theme_font_size_override("font_size", 18)

func _setup_ui():
	category_tabs.clear_tabs()
	category_tabs.add_tab("All")
	for cat in RecipeManager.categories:
		category_tabs.add_tab(cat)

func _switch_state(new_state: GameState):
	var transition = %TransitionOverlay
	var mat = ShaderMaterial.new()
	mat.shader = load("res://assets/pixel_wipe.gdshader")
	transition.material = mat
	mat.set_shader_parameter("progress", 0.0)
	
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/progress", 1.1, 0.4)
	await tween.finished
	
	current_state = new_state
	title_screen.visible = (current_state == GameState.MENU)
	settings_screen.visible = (current_state == GameState.SETTINGS)
	game_screen.visible = (current_state == GameState.GAME)
	
	if current_state == GameState.MENU:
		timer.stop()
	
	var tween_out = create_tween()
	tween_out.tween_property(mat, "shader_parameter/progress", 0.0, 0.4)

func _start_game(mode: GameMode):
	current_mode = mode
	_switch_state(GameState.GAME)
	_clear_board()
	
	blitz_discoveries = 0
	target_emoji = ""
	
	match current_mode:
		GameMode.SANDBOX:
			game_status.text = "SANDBOX"
		GameMode.BLITZ:
			timer.start(180)
			_update_status()
		GameMode.TARGET:
			_pick_random_target()
			_update_status()

func _populate_inventory():
	for child in inventory_box.get_children():
		child.queue_free()
		
	var filter_list = RecipeManager.discovered_emojis
	
	for emoji in filter_list:
		if _matches_filter(emoji):
			_add_to_inventory_ui(emoji)

func _matches_filter(emoji: String) -> bool:
	if selected_category != "All" and RecipeManager.get_category(emoji) != selected_category:
		return false
	if not search_query.is_empty():
		# Simple check: does emoji symbol match or name match (if we had a full name map)
		if not emoji.contains(search_query):
			var found_in_name = false
			for name in emoji_names:
				if emoji_names[name] == emoji and name.contains(search_query):
					found_in_name = true
					break
			if not found_in_name:
				return false
	return true

func _add_to_inventory_ui(emoji: String):
	var piece = preload("res://emoji_piece.tscn").instantiate()
	inventory_box.add_child(piece)
	piece.set_emoji(emoji, true)

# ── Signals ───────────────────────────────────────────────────

func _on_category_tab_changed(tab: int):
	selected_category = category_tabs.get_tab_title(tab)
	_populate_inventory()

func _on_search_text_changed(new_text: String):
	search_query = new_text.strip_edges().to_lower()
	_populate_inventory()

func _on_keyboard_alchemy_submitted(text: String):
	keyboard_alchemy.clear()
	var clean_text = text.strip_edges().to_lower()
	if clean_text.is_empty(): return

	if emoji_names.has(clean_text):
		_spawn_on_board(emoji_names[clean_text])
		return
	
	# Partial matching
	for name in emoji_names:
		if clean_text in name:
			_spawn_on_board(emoji_names[name])
			return

	if clean_text.unicode_at(0) > 127:
		# Direct emoji submission
		_spawn_on_board(clean_text)

	# Implementation of the missing function
func _pick_random_target():
	var all_recipes = RecipeManager.combinations.values()
	var all_results = []
	for results in all_recipes:
		for res in results.values():
			if not all_results.has(res):
				all_results.append(res)
	
	if all_results.size() > 0:
		target_emoji = all_results.pick_random()
	else:
		target_emoji = "💎" # Fallback

# ── Responsive Layout ────────────────────────────────────────

func _on_viewport_resized():
	# In low-res world, we just keep things simple
	inventory_panel.anchors_preset = Control.PRESET_BOTTOM_WIDE
	inventory_panel.custom_minimum_size.y = 180
	inventory_box.columns = 5

func _toggle_inventory():
	is_inventory_open = !is_inventory_open
	var size = get_viewport().get_visible_rect().size
	var target_y = size.y - inventory_panel.size.y if is_inventory_open else size.y
	
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(inventory_panel, "position:y", target_y, 0.3)

func _clear_board():
	for piece in board_area.get_children():
		if piece is CPUParticles2D: continue
		piece.queue_free()

# ── Game Modes ────────────────────────────────────────────────

func _on_mode_selected(index: int):
	pass # Deprecated

func _set_mode(mode: GameMode):
	pass # Deprecated

func _update_status():
	match current_mode:
		GameMode.BLITZ:
			game_status.text = "Blitz: %d discoveries | Time: %d s" % [blitz_discoveries, int(timer.time_left)]
		GameMode.TARGET:
			game_status.text = "Goal: Find %s" % target_emoji
		GameMode.SANDBOX:
			game_status.text = "Mode: Sandbox"

func _process(_delta):
	if current_mode == GameMode.BLITZ and not timer.is_stopped():
		_update_status()

func _on_timer_timeout():
	if current_mode == GameMode.BLITZ:
		_win_game("Blitz Finished! You found %d new emojis." % blitz_discoveries)

func _win_game(msg: String):
	game_status.text = msg
	# Here we could pop up a dialog
	print(msg)

func _spawn_on_board(emoji: String, pos: Vector2 = Vector2.ZERO):
	var piece = preload("res://emoji_piece.tscn").instantiate()
	piece.set_emoji(emoji, false)
	board_area.add_child(piece)
	
	if pos == Vector2.ZERO:
		# Center spawn (keyboard)
		var random_offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
		piece.position = (board_area.size / 2.0) + random_offset - (piece.size / 2.0)
	else:
		# Specific position (merge)
		piece.position = pos - piece.size / 2.0
	
	# Bounce/Pop effect on spawn is already in emoji_piece.gd _ready()

func handle_merge(result: String, pos: Vector2):
	# 1. Particles
	var particles = %MergeParticles
	particles.global_position = pos
	particles.emitting = true
	
	# 2. Spawn result
	_spawn_on_board(result, pos)
	
	# 3. Shake
	screen_shake(0.2, 5.0)

func screen_shake(duration: float, intensity: float):
	var original_pos = position
	var tween = create_tween()
	for i in range(5):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(self, "position", original_pos + offset, duration / 10.0)
		tween.tween_property(self, "position", original_pos, duration / 10.0)

func _on_sequence_discovered(emoji: String):
	if current_mode == GameMode.BLITZ:
		blitz_discoveries += 1
		_update_status()
	
	if current_mode == GameMode.TARGET and emoji == target_emoji:
		_win_game("Target Reached! You found " + emoji)
	
	# Discovery Celebration
	_discovery_celebration(emoji)
	screen_shake(0.4, 12.0)
	
	_populate_inventory()

func _discovery_celebration(emoji: String):
	# 1. Confetti
	var particles = %MergeParticles.duplicate()
	add_child(particles)
	particles.amount = 100
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.initial_velocity_min = 200
	particles.initial_velocity_max = 500
	particles.scale_amount_min = 10
	particles.scale_amount_max = 20
	particles.position = get_viewport().get_visible_rect().size / 2.0
	particles.emitting = true
	get_tree().create_timer(2.0).timeout.connect(particles.queue_free)
	
	# 2. Popup Label
	var label = Label.new()
	label.text = "NEW DISCOVERY!\n" + emoji
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_outline_size", 10)
	label.z_index = 100
	add_child(label)
	
	label.pivot_offset = label.size / 2.0
	label.position = (get_viewport().get_visible_rect().size / 2.0) - (label.size / 2.0)
	label.scale = Vector2.ZERO
	
	var tween = create_tween().set_parallel(false).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Wait a frame for size calculation to be accurate
	await get_tree().process_frame
	label.pivot_offset = label.size / 2.0
	label.position = (get_viewport().get_visible_rect().size / 2.0) - (label.size / 2.0)
	
	tween.tween_property(label, "scale", Vector2.ONE, 0.5)
	tween.tween_property(label, "position:y", label.position.y - 100, 1.5).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.0).set_delay(0.5)
	tween.finished.connect(label.queue_free)

	# 3. Flash
	_discovery_flash()

func _discovery_flash():
	# Simple flash effect by modulating the background or a dedicated overlay
	var bg = $Background
	var original_color = bg.color
	var tween = create_tween()
	tween.tween_property(bg, "color", Color.WHITE, 0.1)
	tween.tween_property(bg, "color", original_color, 0.4)
