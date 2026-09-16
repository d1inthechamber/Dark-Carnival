extends Control

var town := ""
var player_name := ""
var health := 100
var resolve := 100
var cash := 60
var food := 3
var faygo := 2
var tickets := 0
var history: Array[Dictionary] = []
var morality := {"mercy": 0, "greed": 0, "violence": 0, "honesty": 0, "sacrifice": 0, "cruelty": 0}
var deck: Array[String] = ["HATCHET", "FAYGO BREAK", "CARNIVAL SIGHT", "BACK DOOR"]
var hand: Array[String] = []

# Controller state. Godot's built-in ui_* actions already provide stick/D-pad
# navigation and A/Cross activation for focused Controls; these handlers add
# back, shortcuts, shoulder cycling, text entry and rumble.
var current_context := ""
var text_entry_stage := ""
var virtual_keyboard_open := false
var controller_active := false
var last_controller_device := 0

@onready var title: Label = $Margin/VBox/Title
@onready var story: RichTextLabel = $Margin/VBox/Story
@onready var input: LineEdit = $Margin/VBox/Input
@onready var choices: VBoxContainer = $Margin/VBox/Choices
@onready var hud: Label = $Margin/VBox/HUD

func _ready() -> void:
	show_town_prompt()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		controller_active = true
		last_controller_device = event.device
		if not event.pressed:
			return
		match event.button_index:
			JOY_BUTTON_B:
				_controller_back()
				get_viewport().set_input_as_handled()
			JOY_BUTTON_Y:
				if current_context == "thief" or current_context == "thief_after_faygo" or current_context == "thief_revealed":
					open_card_hand()
					get_viewport().set_input_as_handled()
			JOY_BUTTON_LEFT_SHOULDER:
				_controller_focus_step(-1)
				get_viewport().set_input_as_handled()
			JOY_BUTTON_RIGHT_SHOULDER:
				_controller_focus_step(1)
				get_viewport().set_input_as_handled()
	elif event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.25:
			controller_active = true
			last_controller_device = event.device
	elif event is InputEventKey and event.pressed:
		controller_active = false
	elif event is InputEventMouseButton and event.pressed:
		controller_active = false

func show_town_prompt() -> void:
	current_context = "town_entry"
	text_entry_stage = "town"
	virtual_keyboard_open = false
	title.text = "THE DARK CARNIVAL"
	story.text = "[center]Something wicked has come to town.\n\nSometime after midnight, trucks began rolling in. By morning, an enormous carnival stood where yesterday there was nothing.\n\nNobody remembers seeing it arrive.\n\n[b]Where are you?[/b]\n\n[i]Gamepad: use the controller keyboard below for controller-only play.[/i][/center]"
	input.visible = true
	input.placeholder_text = "Enter your town"
	clear_choices()
	add_choice("CONTINUE", submit_town)
	add_choice("🎮 CONTROLLER KEYBOARD", func(): open_virtual_keyboard("town"))
	update_hud(false)

func show_name_prompt() -> void:
	current_context = "name_entry"
	text_entry_stage = "name"
	virtual_keyboard_open = false
	input.visible = true
	input.placeholder_text = "Enter your name"
	story.text = "[center][b]WELCOME TO %s[/b]\n\nTHE DARK CARNIVAL IS NOW OPEN\n\nAdmission is free.\nLeaving may cost considerably more.\n\nWhat is your name?\n\n[i]Gamepad: use the controller keyboard below for controller-only play.[/i][/center]" % town.to_upper()
	clear_choices()
	add_choice("ENTER THE MIDWAY", submit_name)
	add_choice("🎮 CONTROLLER KEYBOARD", func(): open_virtual_keyboard("name"))

func submit_town() -> void:
	if input.text.strip_edges().is_empty():
		if controller_active:
			open_virtual_keyboard("town")
		return
	town = input.text.strip_edges()
	input.text = ""
	show_name_prompt()

func submit_name() -> void:
	if input.text.strip_edges().is_empty():
		if controller_active:
			open_virtual_keyboard("name")
		return
	player_name = input.text.strip_edges()
	input.visible = false
	virtual_keyboard_open = false
	start_gate()

func open_virtual_keyboard(stage: String) -> void:
	text_entry_stage = stage
	virtual_keyboard_open = true
	current_context = stage + "_keyboard"
	clear_choices()
	var grid := GridContainer.new()
	grid.columns = 7
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	choices.add_child(grid)
	var keys: Array[String] = [
		"A", "B", "C", "D", "E", "F", "G",
		"H", "I", "J", "K", "L", "M", "N",
		"O", "P", "Q", "R", "S", "T", "U",
		"V", "W", "X", "Y", "Z", "0", "1",
		"2", "3", "4", "5", "6", "7", "8",
		"9", "-", "'", ".", "SPACE", "⌫", "DONE"
	]
	for key_text in keys:
		var key_button := Button.new()
		key_button.text = key_text
		key_button.custom_minimum_size = Vector2(90, 44)
		key_button.focus_mode = Control.FOCUS_ALL
		key_button.pressed.connect(func(): _virtual_key_pressed(key_text))
		grid.add_child(key_button)
	call_deferred("_focus_first_choice")

func _virtual_key_pressed(key_text: String) -> void:
	match key_text:
		"SPACE":
			input.text += " "
		"⌫":
			if not input.text.is_empty():
				input.text = input.text.left(input.text.length() - 1)
		"DONE":
			virtual_keyboard_open = false
			if text_entry_stage == "town":
				submit_town()
			else:
				submit_name()
		_:
			input.text += key_text

func _controller_back() -> void:
	if virtual_keyboard_open:
		virtual_keyboard_open = false
		if text_entry_stage == "town":
			show_town_prompt()
		else:
			show_name_prompt()
		return
	match current_context:
		"card_hand":
			thief_event_without_loss()
		"name_entry":
			input.text = ""
			town = ""
			show_town_prompt()
		_:
			pass

func _controller_focus_step(direction: int) -> void:
	var buttons: Array[Button] = []
	_collect_focusable_buttons(choices, buttons)
	if buttons.is_empty():
		return
	var focused := get_viewport().gui_get_focus_owner()
	var index := buttons.find(focused)
	if index < 0:
		index = 0
	else:
		index = wrapi(index + direction, 0, buttons.size())
	buttons[index].grab_focus()

func _collect_focusable_buttons(node: Node, output: Array[Button]) -> void:
	for child in node.get_children():
		if child is Button and not child.is_queued_for_deletion() and child.visible and child.disabled == false:
			output.append(child)
		_collect_focusable_buttons(child, output)

func _focus_first_choice() -> void:
	var buttons: Array[Button] = []
	_collect_focusable_buttons(choices, buttons)
	if not buttons.is_empty():
		buttons[0].grab_focus()

func _rumble(weak: float = 0.25, strong: float = 0.55, duration: float = 0.18) -> void:
	if Input.get_connected_joypads().has(last_controller_device):
		Input.start_joy_vibration(last_controller_device, weak, strong, duration)

func start_gate() -> void:
	current_context = "gate"
	title.text = "CARNIVAL OF CARNAGE — THE GATES"
	story.text = "The midway glows against the night over %s. A clown beside the entrance silently waves you through.\n\nThe instant you cross the threshold—\n\n[b]CLANG.[/b]\n\nThe iron gates lock behind you." % town
	clear_choices(); add_choice("Ask the clown about the gate", gate_clown); add_choice("Try to force the gate open", gate_force); add_choice("Ignore it and enter the midway", thief_event); update_hud()
	_rumble(0.15, 0.45, 0.16)

func gate_clown() -> void:
	current_context = "gate_clown"
	story.text = "The clown's painted smile doesn't move. He points toward the midway.\n\n\"Everybody gets out eventually.\""
	clear_choices(); add_choice("Enter the midway", thief_event)

func gate_force() -> void:
	current_context = "gate_force"
	resolve = max(0, resolve - 5); record("locked_gate", "tried_to_escape", {})
	story.text = "The gate doesn't move. For a moment you swear something on the other side pulls back.\n\n[b]Resolve -5[/b]"
	clear_choices(); add_choice("Enter the midway", thief_event); update_hud(); _rumble(0.35, 0.7, 0.22)

func thief_event() -> void:
	current_context = "thief"
	cash = max(0, cash - 20)
	story.text = "A teenager slams into your shoulder and vanishes into the crowd.\n\nYou check your pocket.\n\n[b]$20 is gone.[/b]\n\nA battered card case at your belt suddenly flips open. The Carnival is offering another way.\n\n[i]Gamepad shortcut: Y/Triangle opens your cards.[/i]"
	clear_choices(); add_choice("CHASE HIM", chase_thief); add_choice("LET HIM GO", let_thief_go); add_choice("CALL FOR HELP", call_for_help); add_choice("PLAY A CARD", open_card_hand); update_hud(); _rumble(0.1, 0.25, 0.1)

func open_card_hand() -> void:
	current_context = "card_hand"
	hand = deck.duplicate()
	story.text = "[center][b]YOUR HAND[/b]\n\nCards resolve immediately. Some solve problems. Some merely change what kind of problem you have.\n\n[i]The Carnival remembers how you use them.\nGamepad: D-pad/stick selects • A/Cross plays • B/Circle backs out • LB/RB cycles.[/i][/center]"
	clear_choices()
	for card_name in hand:
		add_choice(card_name + " — " + card_description(card_name), func(): play_card(card_name))
	add_choice("PUT THE CARDS AWAY", thief_event_without_loss)

func thief_event_without_loss() -> void:
	current_context = "thief"
	story.text = "The thief is still somewhere in the crowd. Your $20 is still gone.\n\n[i]Gamepad shortcut: Y/Triangle opens your cards.[/i]"
	clear_choices(); add_choice("CHASE HIM", chase_thief); add_choice("LET HIM GO", let_thief_go); add_choice("CALL FOR HELP", call_for_help); add_choice("PLAY A CARD", open_card_hand)

func card_description(card_name: String) -> String:
	match card_name:
		"HATCHET": return "recover the cash; violence rises"
		"FAYGO BREAK": return "spend 1 Faygo; restore Resolve"
		"CARNIVAL SIGHT": return "reveal the danger behind CALL FOR HELP"
		"BACK DOOR": return "escape this encounter; lose Resolve"
	return "unknown"

func play_card(card_name: String) -> void:
	record("pickpocket_card", card_name.to_lower().replace(" ", "_"), {"cash": cash, "faygo": faygo, "resolve": resolve})
	match card_name:
		"HATCHET":
			cash += 20; morality["violence"] += 1
			story.text = "The HATCHET card snaps from your hand like a thrown blade. For one impossible second the midway becomes black ink and neon red.\n\nThe thief drops the money and runs.\n\n[b]Cash recovered. Violence remembered.[/b]"
			_rumble(0.45, 0.9, 0.28); finish_slice()
		"FAYGO BREAK":
			if faygo <= 0:
				story.text = "You reach for a bottle. Empty. The card laughs at you."; clear_choices(); add_choice("BACK TO YOUR HAND", open_card_hand); _rumble(0.1, 0.2, 0.1); return
			faygo -= 1; resolve = min(100, resolve + 20); current_context = "thief_after_faygo"
			story.text = "You crack a cold Faygo. Neon fizz sprays across the card face as the noise of the midway briefly becomes music.\n\n[b]Faygo -1. Resolve +20.[/b]\n\nThe thief is getting away.\n\n[i]Y/Triangle reopens your cards.[/i]"
			clear_choices(); add_choice("CHASE HIM", chase_thief); add_choice("LET HIM GO", let_thief_go); add_choice("CALL FOR HELP", call_for_help); update_hud(); _rumble(0.12, 0.18, 0.14)
		"CARNIVAL SIGHT":
			resolve = max(0, resolve - 3); current_context = "thief_revealed"
			story.text = "The card's eye opens. You see CALL FOR HELP before you choose it: a carnival worker catches the kid... and does not stop after recovering your money.\n\n[b]Resolve -3. A consequence has been revealed.[/b]\n\n[i]Y/Triangle reopens your cards.[/i]"
			clear_choices(); add_choice("CALL FOR HELP ANYWAY", call_for_help); add_choice("CHASE HIM", chase_thief); add_choice("LET HIM GO", let_thief_go); update_hud(); _rumble(0.08, 0.22, 0.18)
		"BACK DOOR":
			resolve = max(0, resolve - 8); morality["honesty"] -= 1
			story.text = "A painted door appears where there wasn't one. You step through and emerge two tents away. The thief—and your money—are gone.\n\n[b]Resolve -8. Encounter escaped.[/b]"
			_rumble(0.15, 0.4, 0.2); finish_slice()

func chase_thief() -> void:
	current_context = "thief_chase"
	health = max(0, health - 8); cash += 20; morality["violence"] += 1; record("pickpocket", "chased", {"health_cost": 8})
	story.text = "You catch him between two tents. After a struggle, you recover the money, but leave bleeding from the elbow.\n\n[b]Cash recovered. Health -8.[/b]"; _rumble(0.4, 0.65, 0.24); finish_slice()

func let_thief_go() -> void:
	current_context = "thief_mercy"
	morality["mercy"] += 1; record("pickpocket", "let_go", {"money_lost": 20})
	story.text = "You watch him disappear. Somewhere beyond the lights, a calliope begins playing a tune you almost recognize."; finish_slice()

func call_for_help() -> void:
	current_context = "worker_choice"
	story.text = "A huge carnival worker catches the kid within seconds. He retrieves your money—then knocks the teenager down and keeps hitting him.\n\nThe worker looks back at you.\n\n\"This what you wanted?\""
	clear_choices(); add_choice("STOP THE WORKER", stop_worker); add_choice("Take your money and leave", take_money); add_choice("Watch", watch_worker); add_choice("Help the worker", help_worker); _rumble(0.2, 0.5, 0.16)

func stop_worker() -> void:
	cash += 20; health = max(0, health - 10); morality["mercy"] += 2; morality["sacrifice"] += 1; record("worker_beating", "intervened", {"health_cost": 10})
	story.text = "You step between them. The worker shoves you hard, but finally backs away. The kid stares at you before running into the darkness.\n\n[b]Cash recovered. Health -10.[/b]"; _rumble(0.4, 0.75, 0.25); finish_slice()

func take_money() -> void:
	cash += 20; morality["greed"] += 1; record("worker_beating", "took_money", {})
	story.text = "You take the crumpled bills from the pavement and walk away. The sounds behind you continue longer than you expected."; finish_slice()

func watch_worker() -> void:
	resolve = max(0, resolve - 10); morality["cruelty"] += 1; record("worker_beating", "watched", {})
	story.text = "You do nothing. Eventually the worker stops.\n\nHe smiles at you as though the two of you now share a secret.\n\n[b]Resolve -10.[/b]"; _rumble(0.12, 0.3, 0.18); finish_slice()

func help_worker() -> void:
	cash += 20; morality["violence"] += 2; morality["cruelty"] += 2; record("worker_beating", "joined", {})
	story.text = "For a few terrible seconds, you join in. When it's over, the worker hands back your money.\n\n\"Carnival remembers its friends.\""; _rumble(0.5, 0.9, 0.3); finish_slice()

func finish_slice() -> void:
	current_context = "slice_finish"
	update_hud(); clear_choices(); add_choice("CONTINUE INTO CARNIVAL OF CARNAGE", preview_map)

func preview_map() -> void:
	current_context = "preview"
	title.text = "THE DARK CARNIVAL"
	story.text = "[center][b]CARNIVAL OF CARNAGE[/b] — OPEN\n\nRINGMASTER — LOCKED\nRIDDLE BOX — LOCKED\nTHE GREAT MILENKO — LOCKED\nTHE AMAZING JECKEL BROTHERS — LOCKED\nTHE WRAITH — ?\n\n[i]The carnival remembers everything.[/i]\n\n[b]SYSTEMS ACTIVE:[/b] Cards + Faygo + Full Gamepad Navigation\n\nGamepad: D-pad/Stick navigate • A/Cross confirm • B/Circle back • LB/RB cycle • Y/Triangle cards\n\nBuild 0.2 systems prototype.[/center]"
	clear_choices(); add_choice("PLAY AGAIN", reset_game)

func reset_game() -> void:
	health = 100; resolve = 100; cash = 60; food = 3; faygo = 2; tickets = 0; history.clear(); hand.clear()
	for key in morality.keys(): morality[key] = 0
	town = ""; player_name = ""; input.text = ""; current_context = ""; text_entry_stage = ""; virtual_keyboard_open = false; show_town_prompt()

func record(event_name: String, choice: String, context: Dictionary) -> void:
	history.append({"event": event_name, "choice": choice, "context": context})

func update_hud(show_stats := true) -> void:
	hud.visible = show_stats; hud.text = "HEALTH %d   RESOLVE %d   CASH $%d   FOOD %d   FAYGO %d   TICKETS %d" % [health, resolve, cash, food, faygo, tickets]

func clear_choices() -> void:
	for child in choices.get_children():
		child.queue_free()
	call_deferred("_focus_first_choice")

func add_choice(label: String, callback: Callable) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size.y = 44
	button.focus_mode = Control.FOCUS_ALL
	button.pressed.connect(callback)
	choices.add_child(button)
