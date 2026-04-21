extends Control

@onready var inventory_box = %InventoryBox
@onready var board_area = $VBoxContainer/BoardArea
@onready var keyboard_alchemy = %KeyboardAlchemy
@onready var category_tabs = %CategoryTabs
@onready var mode_selector = %ModeSelector
@onready var game_status = %GameStatus
@onready var timer = $Timer

enum GameMode { SANDBOX, BLITZ, TARGET }

var current_mode = GameMode.SANDBOX
var search_query: String = ""
var selected_category: String = "All"
var target_emoji: String = ""
var blitz_discoveries: int = 0

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
	"milk": "🥛", "ice": "🧊", "snow": "❄️", "sun": "☀️",
	"music": "🎶", "car": "🚗", "plane": "✈️", "ship": "🚢",
	"house": "🏠", "city": "🏙️", "night": "🌃", "day": "🌅"
}

func _ready():
	_setup_ui()
	_populate_inventory()
	RecipeManager.sequence_discovered.connect(_on_sequence_discovered)
	RecipeManager.request_merge.connect(handle_merge)
	keyboard_alchemy.text_submitted.connect(_on_keyboard_alchemy_submitted)
	keyboard_alchemy.text_changed.connect(_on_search_text_changed)
	category_tabs.tab_changed.connect(_on_category_tab_changed)
	mode_selector.item_selected.connect(_on_mode_selected)
	timer.timeout.connect(_on_timer_timeout)

func _setup_ui():
	# Populate Category Tabs
	category_tabs.clear_tabs()
	category_tabs.add_tab("All")
	for cat in RecipeManager.categories:
		category_tabs.add_tab(cat)
	
	mode_selector.selected = 0
	_set_mode(GameMode.SANDBOX)

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

# ── Game Modes ────────────────────────────────────────────────

func _on_mode_selected(index: int):
	_set_mode(index as GameMode)

func _set_mode(mode: GameMode):
	current_mode = mode
	timer.stop()
	blitz_discoveries = 0
	target_emoji = ""
	
	match current_mode:
		GameMode.SANDBOX:
			game_status.text = "Mode: Sandbox"
		GameMode.BLITZ:
			timer.start(180) # 3 minutes
			_update_status()
		GameMode.TARGET:
			_pick_random_target()
			_update_status()
	
	# Clear board for fresh mode start
	for piece in board_area.get_children():
		piece.queue_free()

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
	
	# Discovery Juice
	_discovery_flash()
	screen_shake(0.4, 12.0) # Bigger shake for new stuff
	
	_populate_inventory()

func _discovery_flash():
	# Simple flash effect by modulating the background or a dedicated overlay
	var bg = $Background
	var original_color = bg.color
	var tween = create_tween()
	tween.tween_property(bg, "color", Color.WHITE, 0.1)
	tween.tween_property(bg, "color", original_color, 0.4)
