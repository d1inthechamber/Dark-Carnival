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
var morality := {"mercy":0,"greed":0,"violence":0,"honesty":0,"sacrifice":0,"cruelty":0}
var deck: Array[String] = ["HATCHET","FAYGO BREAK","CARNIVAL SIGHT","BACK DOOR"]
var current_context := ""
var text_entry_stage := ""
var virtual_keyboard_open := false
var controller_active := false
var last_controller_device := 0

@onready var title: Label = $Margin/VBox/Header/Title
@onready var story: RichTextLabel = $Margin/VBox/ComicFrame/Margin/Layout/Story
@onready var scene_label: Label = $Margin/VBox/ComicFrame/Margin/Layout/ArtStage/ArtStack/SceneLabel
@onready var input: LineEdit = $Margin/VBox/Input
@onready var choices: VBoxContainer = $Margin/VBox/ChoiceList/Margin/ChoicesScroll/Choices
@onready var hud: Label = $Margin/VBox/HUDBar/Margin/HUD
@onready var card_hand: PanelContainer = $Margin/VBox/CardHand
@onready var card_hint: Label = $Margin/VBox/CardHand/Margin/Row/CardHint
@onready var transition_fx: Control = $TransitionFX
@onready var comic_frame: PanelContainer = $Margin/VBox/ComicFrame

func _ready() -> void:
	show_town_prompt()

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		controller_active = true
		last_controller_device = event.device
		if not event.pressed: return
		match event.button_index:
			JOY_BUTTON_B:
				controller_back(); get_viewport().set_input_as_handled()
			JOY_BUTTON_Y:
				if current_context.begins_with("thief"):
					open_card_hand(); get_viewport().set_input_as_handled()
			JOY_BUTTON_LEFT_SHOULDER:
				focus_step(-1); get_viewport().set_input_as_handled()
			JOY_BUTTON_RIGHT_SHOULDER:
				focus_step(1); get_viewport().set_input_as_handled()
	elif event is InputEventJoypadMotion and abs(event.axis_value) > 0.25:
		controller_active = true; last_controller_device = event.device
	elif (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
		controller_active = false

func show_town_prompt() -> void:
	current_context = "town_entry"; text_entry_stage = "town"; virtual_keyboard_open = false
	title.text = "THE DARK CARNIVAL"
	set_scene("THE TOWN BEFORE THE MIDWAY")
	set_card_shell(false)
	story.text = "[center]Something wicked has come to town.\n\nSometime after midnight, trucks began rolling in. By morning, an enormous carnival stood where yesterday there was nothing.\n\nNobody remembers seeing it arrive.\n\n[b]Where are you?[/b][/center]"
	input.visible = true; input.placeholder_text = "Enter your town"
	clear_choices(); add_choice("CONTINUE", submit_town); add_choice("CONTROLLER KEYBOARD", func(): open_virtual_keyboard("town")); update_hud(false)

func show_name_prompt() -> void:
	current_context = "name_entry"; text_entry_stage = "name"; virtual_keyboard_open = false
	set_scene("ADMISSION IS FREE")
	set_card_shell(false)
	input.visible = true; input.placeholder_text = "Enter your name"
	story.text = "[center][b]WELCOME TO %s[/b]\n\nTHE DARK CARNIVAL IS NOW OPEN\n\nAdmission is free. Leaving may cost considerably more.\n\nWhat is your name?[/center]" % town.to_upper()
	clear_choices(); add_choice("ENTER THE MIDWAY", submit_name); add_choice("CONTROLLER KEYBOARD", func(): open_virtual_keyboard("name"))

func submit_town() -> void:
	if input.text.strip_edges().is_empty():
		if controller_active: open_virtual_keyboard("town")
		return
	town = input.text.strip_edges(); input.text = ""; show_name_prompt()

func submit_name() -> void:
	if input.text.strip_edges().is_empty():
		if controller_active: open_virtual_keyboard("name")
		return
	player_name = input.text.strip_edges(); input.visible = false; virtual_keyboard_open = false; start_gate()

func open_virtual_keyboard(stage: String) -> void:
	text_entry_stage = stage; virtual_keyboard_open = true; current_context = stage + "_keyboard"; set_card_shell(false); clear_choices()
	var grid := GridContainer.new(); grid.columns = 7; grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL; choices.add_child(grid)
	var keys: Array[String] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9","-","'",".","SPACE","BACK","DONE"]
	for key_text in keys:
		var b := Button.new(); b.text = key_text; b.custom_minimum_size = Vector2(90,44); b.focus_mode = Control.FOCUS_ALL
		apply_choice_style(b)
		b.pressed.connect(func(): virtual_key(key_text)); grid.add_child(b)
	call_deferred("focus_first_choice")

func virtual_key(key_text: String) -> void:
	match key_text:
		"SPACE": input.text += " "
		"BACK":
			if not input.text.is_empty(): input.text = input.text.left(input.text.length()-1)
		"DONE":
			virtual_keyboard_open = false
			if text_entry_stage == "town": submit_town()
			else: submit_name()
		_: input.text += key_text

func start_gate() -> void:
	current_context = "gate"; title.text = "CARNIVAL OF CARNAGE — THE GATES"; set_scene("THE GATES // CARNIVAL OF CARNAGE"); set_card_shell(false)
	story.text = "The midway glows against the night over %s. A clown silently waves you through.\n\nThe instant you cross the threshold—\n\n[b]CLANG.[/b]\n\nThe iron gates lock behind you." % town
	clear_choices(); add_choice("Ask the clown about the gate", gate_clown); add_choice("Try to force the gate open", gate_force); add_choice("Enter the midway", thief_event); update_hud(); rumble(.15,.45,.16); impact_flash("CLANG", Color(0.95,0.08,0.22,1))

func gate_clown() -> void:
	set_scene("THE CLOWN AT THE GATE")
	story.text = "The clown's painted smile doesn't move. He points toward the midway.\n\n\"Everybody gets out eventually.\""; clear_choices(); add_choice("Enter the midway", thief_event)

func gate_force() -> void:
	resolve = max(0,resolve-5); record("locked_gate","tried_to_escape"); set_scene("IRON AGAINST IRON")
	story.text = "The gate doesn't move. Something on the other side seems to pull back.\n\n[b]Resolve -5[/b]"; clear_choices(); add_choice("Enter the midway", thief_event); update_hud(); rumble(.35,.7,.22); impact_flash("NO EXIT", Color(0.72,0.12,0.88,1))

func thief_event() -> void:
	current_context = "thief"; cash = max(0,cash-20); set_scene("THE MIDWAY // SOMEBODY HIT YOUR SHOULDER"); set_card_shell(false)
	story.text = "A teenager slams into your shoulder and vanishes into the crowd.\n\n[b]$20 is gone.[/b]\n\nA battered card case at your belt flips open. The Carnival is offering another way."
	clear_choices(); add_choice("CHASE HIM", chase_thief); add_choice("LET HIM GO", let_thief_go); add_choice("CALL FOR HELP", call_for_help); add_choice("PLAY A CARD", open_card_hand); update_hud(); impact_flash("- $20", Color(0.95,0.08,0.22,1))

func open_card_hand() -> void:
	current_context = "card_hand"; set_scene("THE CARDS ARE WATCHING"); set_card_shell(true, "Choose carefully. Cards solve problems, but the Carnival remembers how.")
	story.text = "[center][b]YOUR HAND[/b]\n\nCards are physical choices now. Pick one and live with what it says about you.\n\n[i]D-pad/stick selects • A/Cross plays • B/Circle backs out • LB/RB cycles[/i][/center]"
	build_card_grid()

func card_description(card_name: String) -> String:
	match card_name:
		"HATCHET": return "recover cash; violence rises"
		"FAYGO BREAK": return "spend 1 Faygo; restore Resolve"
		"CARNIVAL SIGHT": return "reveal the danger behind CALL FOR HELP"
		"BACK DOOR": return "escape encounter; lose Resolve"
	return "unknown"

func build_card_grid() -> void:
	clear_choices()
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	choices.add_child(grid)

	for card_name in deck:
		var card := Button.new()
		card.text = card_title(card_name) + "\n" + card_description(card_name).to_upper()
		card.custom_minimum_size = Vector2(0, 92)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.focus_mode = Control.FOCUS_ALL
		card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		apply_card_style(card, card_name)
		card.pressed.connect(play_card.bind(card_name))
		grid.add_child(card)

	add_choice("PUT THE CARDS AWAY", thief_resume)
	call_deferred("focus_first_choice")

func card_title(card_name: String) -> String:
	match card_name:
		"HATCHET": return "I  //  HATCHET"
		"FAYGO BREAK": return "II  //  FAYGO BREAK"
		"CARNIVAL SIGHT": return "III  //  CARNIVAL SIGHT"
		"BACK DOOR": return "IV  //  BACK DOOR"
	return card_name

func card_accent(card_name: String) -> Color:
	match card_name:
		"HATCHET": return Color(0.96,0.08,0.22,1)
		"FAYGO BREAK": return Color(0.1,0.9,0.95,1)
		"CARNIVAL SIGHT": return Color(0.72,1,0.18,1)
		"BACK DOOR": return Color(0.72,0.12,0.9,1)
	return Color(0.95,0.15,0.55,1)

func apply_card_style(button:Button, card_name:String) -> void:
	var accent := card_accent(card_name)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color(0.94,0.92,0.86,1))
	button.add_theme_color_override("font_focus_color", Color(0.03,0.02,0.04,1))
	button.add_theme_color_override("font_hover_color", accent)
	button.add_theme_stylebox_override("normal", make_card_style(Color(0.025,0.018,0.04,1), accent.darkened(0.35), 2))
	button.add_theme_stylebox_override("hover", make_card_style(Color(0.06,0.025,0.075,1), accent, 3))
	button.add_theme_stylebox_override("focus", make_card_style(accent, Color(0.98,0.95,0.86,1), 4))
	button.add_theme_stylebox_override("pressed", make_card_style(accent.darkened(0.2), Color(1,1,1,1), 4))

func make_card_style(bg:Color, border:Color, width:int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	return style

func play_card(card_name: String) -> void:
	record("pickpocket_card",card_name)
	match card_name:
		"HATCHET":
			cash += 20; morality["violence"] += 1; set_card_shell(false); set_scene("HATCHET // IMPACT")
			story.text = "The HATCHET card snaps forward like a thrown blade. The thief drops the money and runs.\n\n[b]Cash recovered. Violence remembered.[/b]"; rumble(.45,.9,.28); impact_flash("HATCHET", Color(0.96,0.08,0.22,1)); midway_crossroads()
		"FAYGO BREAK":
			if faygo <= 0: story.text = "You reach for a bottle. Empty."; clear_choices(); add_choice("BACK",open_card_hand); return
			faygo -= 1; resolve = min(100,resolve+20); current_context = "thief_resume"; set_card_shell(false); set_scene("FAYGO BREAK")
			story.text = "You crack a cold Faygo. The midway noise briefly becomes music.\n\n[b]Faygo -1. Resolve +20.[/b]"; thief_choices(); update_hud(); impact_flash("FSSSHHH!", Color(0.1,0.9,0.95,1))
		"CARNIVAL SIGHT":
			resolve = max(0,resolve-3); current_context = "thief_resume"; set_card_shell(false); set_scene("CARNIVAL SIGHT")
			story.text = "The card's eye opens. You see CALL FOR HELP before choosing it: a worker catches the kid... and keeps hitting him after the money is recovered.\n\n[b]Resolve -3.[/b]"; thief_choices(); update_hud(); impact_flash("YOU SAW IT", Color(0.68,0.95,0.18,1))
		"BACK DOOR":
			resolve = max(0,resolve-8); morality["honesty"] -= 1; set_card_shell(false); set_scene("THE PAINTED DOOR")
			story.text = "A painted door appears. You step through and emerge two tents away. The thief—and your money—are gone.\n\n[b]Resolve -8.[/b]"; impact_flash("GONE", Color(0.72,0.12,0.9,1)); midway_crossroads()

func thief_resume() -> void:
	current_context = "thief_resume"; set_card_shell(false); set_scene("THE THIEF IS GETTING AWAY"); story.text = "The thief is still somewhere in the crowd. Your $20 is still gone."; thief_choices()

func thief_choices() -> void:
	clear_choices(); add_choice("CHASE HIM",chase_thief); add_choice("LET HIM GO",let_thief_go); add_choice("CALL FOR HELP",call_for_help); add_choice("PLAY A CARD",open_card_hand)

func chase_thief() -> void:
	health = max(0,health-8); cash += 20; morality["violence"] += 1; record("pickpocket","chased"); set_scene("THE CHASE")
	story.text = "You catch him between two tents. You recover the money but leave bleeding.\n\n[b]Cash recovered. Health -8.[/b]"; rumble(.4,.65,.24); impact_flash("CAUGHT", Color(0.95,0.08,0.22,1)); midway_crossroads()

func let_thief_go() -> void:
	morality["mercy"] += 1; record("pickpocket","let_go"); set_scene("THE CROWD SWALLOWS HIM")
	story.text = "You watch him disappear. Somewhere beyond the lights, a calliope plays a tune you almost recognize."; midway_crossroads()

func call_for_help() -> void:
	set_scene("THE CARNIVAL ANSWERS")
	story.text = "A huge carnival worker catches the kid and retrieves your money—then knocks him down and keeps hitting him.\n\n\"This what you wanted?\""; clear_choices(); add_choice("STOP THE WORKER",stop_worker); add_choice("Take your money and leave",take_money); add_choice("Watch",watch_worker); add_choice("Help the worker",help_worker)

func stop_worker() -> void:
	cash += 20; health=max(0,health-10); morality["mercy"]+=2; morality["sacrifice"]+=1; record("worker","intervened"); set_scene("STEP BETWEEN THEM")
	story.text="You step between them. The worker shoves you hard, but backs away.\n\n[b]Cash recovered. Health -10.[/b]"; impact_flash("ENOUGH", Color(0.68,0.95,0.18,1)); midway_crossroads()

func take_money() -> void:
	cash+=20; morality["greed"]+=1; record("worker","took_money"); set_scene("YOU TAKE THE MONEY")
	story.text="You take the crumpled bills and walk away. The sounds behind you continue too long."; midway_crossroads()

func watch_worker() -> void:
	resolve=max(0,resolve-10); morality["cruelty"]+=1; record("worker","watched"); set_scene("YOU WATCH")
	story.text="You do nothing. The worker eventually stops and smiles as though you share a secret.\n\n[b]Resolve -10.[/b]"; midway_crossroads()

func help_worker() -> void:
	cash+=20; morality["violence"]+=2; morality["cruelty"]+=2; record("worker","joined"); set_scene("THE CARNIVAL REMEMBERS ITS FRIENDS")
	story.text="For a few terrible seconds, you join in. The worker hands back your money.\n\n\"Carnival remembers its friends.\""; impact_flash("REMEMBERED", Color(0.95,0.08,0.22,1)); midway_crossroads()

func midway_crossroads() -> void:
	current_context="crossroads"; set_card_shell(false); update_hud(); clear_choices(); add_choice("CONTINUE TO THE MIDWAY",bottle_game)

func bottle_game() -> void:
	current_context="bottles"; title.text="CARNIVAL OF CARNAGE — THE MIDWAY"; set_scene("MILK BOTTLES // ONE TICKET")
	story.text="A booth operator taps three milk bottles with a cane.\n\n\"Three throws. Ten bucks. Knock 'em down and I'll give you a ticket.\"\n\nBehind him, a small girl watches a stuffed rabbit hanging from the prize rack."
	clear_choices(); add_choice("PAY $10 AND PLAY",play_bottles); add_choice("CHEAT WHILE HE LOOKS AWAY",cheat_bottles); add_choice("BUY THE GIRL A PRIZE — $15",buy_prize); add_choice("KEEP WALKING",mirror_tent)

func play_bottles() -> void:
	if cash < 10: story.text="You check your pockets. Not enough."; clear_choices(); add_choice("KEEP WALKING",mirror_tent); return
	cash-=10; tickets+=1; morality["honesty"]+=1; record("bottle_game","played_fair"); set_scene("THIRD THROW")
	story.text="The first throw misses. The second clips the top bottle. The third sends all three crashing down.\n\nThe operator's grin vanishes.\n\n[b]Ticket +1. Cash -$10.[/b]"; update_hud(); impact_flash("CRASH!", Color(0.96,0.8,0.1,1)); clear_choices(); add_choice("MOVE ON",mirror_tent)

func cheat_bottles() -> void:
	tickets+=1; morality["honesty"]-=2; morality["greed"]+=1; record("bottle_game","cheated"); set_scene("HE KNOWS")
	story.text="While the operator turns, you kick the hidden brace beneath the counter. One throw topples everything.\n\nHe knows. He gives you the ticket anyway.\n\n[b]Ticket +1. The Carnival noticed.[/b]"; update_hud(); impact_flash("CHEAT", Color(0.72,0.12,0.9,1)); clear_choices(); add_choice("MOVE ON",mirror_tent)

func buy_prize() -> void:
	if cash < 15: story.text="You cannot afford it."; clear_choices(); add_choice("KEEP WALKING",mirror_tent); return
	cash-=15; morality["mercy"]+=1; morality["sacrifice"]+=1; record("bottle_game","gifted_prize"); set_scene("THE STUFFED RABBIT")
	story.text="You buy the rabbit and hand it to the girl. She hugs it, then presses a paper ticket into your palm.\n\n\"I found this. You need it more.\"\n\n[b]Cash -$15. Ticket +1.[/b]"; tickets+=1; update_hud(); clear_choices(); add_choice("MOVE ON",mirror_tent)

func mirror_tent() -> void:
	current_context="mirrors"; title.text="CARNIVAL OF CARNAGE — MIRROR MAZE"; set_scene("EVERY REFLECTION MADE A DIFFERENT CHOICE")
	story.text="The midway narrows into a tent of warped mirrors. Every reflection is you—but each one made a different choice tonight.\n\nOne reflection knocks from inside the glass.\n\n\"Trade me something real and I'll show you the exit.\""
	clear_choices(); add_choice("GIVE UP 1 FAYGO",mirror_faygo); add_choice("BREAK THE MIRROR",mirror_break); add_choice("TRUST YOURSELF",mirror_trust)

func mirror_faygo() -> void:
	if faygo<=0: story.text="You have no Faygo to offer."; clear_choices(); add_choice("BREAK THE MIRROR",mirror_break); add_choice("TRUST YOURSELF",mirror_trust); return
	faygo-=1; resolve=min(100,resolve+10); record("mirror_maze","paid_reflection"); set_scene("THE REFLECTION DRINKS")
	story.text="The bottle vanishes through the glass. Your reflection drinks, smiles, and points to a seam in the darkness.\n\n[b]Faygo -1. Resolve +10.[/b]"; update_hud(); clear_choices(); add_choice("FOLLOW THE EXIT",finale_gate)

func mirror_break() -> void:
	health=max(0,health-12); morality["violence"]+=1; record("mirror_maze","broke_mirror"); set_scene("SHATTER")
	story.text="You smash through. Glass bites your hands, but cold night air waits beyond the last pane.\n\n[b]Health -12.[/b]"; rumble(.45,.8,.25); impact_flash("KRAK!", Color(0.1,0.9,0.95,1)); update_hud(); clear_choices(); add_choice("CLIMB THROUGH",finale_gate)

func mirror_trust() -> void:
	var penalty := 8
	if morality["honesty"] >= 1 or morality["mercy"] >= 2: penalty=0
	resolve=max(0,resolve-penalty); record("mirror_maze","trusted_self"); set_scene("STOP WATCHING THE REFLECTIONS")
	if penalty==0: story.text="You stop watching the reflections and listen to your own footsteps. The false paths go silent. You find the exit untouched."
	else: story.text="You wander until the reflections begin whispering your name. Eventually you find the exit.\n\n[b]Resolve -8.[/b]"
	update_hud(); clear_choices(); add_choice("STEP OUTSIDE",finale_gate)

func finale_gate() -> void:
	current_context="finale"; title.text="CARNIVAL OF CARNAGE — LAST CALL"; set_scene("ONE SOUL // ONE NIGHT // ONE WAY OUT")
	story.text="You emerge behind the midway. The locked entrance gate stands ahead. A brass ticket reader blinks beside it.\n\nAbove you, loudspeakers crackle.\n\n\"ONE SOUL. ONE NIGHT. ONE WAY OUT.\""
	clear_choices()
	if tickets>0: add_choice("INSERT A TICKET",use_ticket)
	add_choice("FORCE THE EXIT",force_exit)
	add_choice("TURN BACK TOWARD THE CARNIVAL",turn_back)

func use_ticket() -> void:
	tickets-=1; record("level_exit","ticket"); set_scene("EVERY LIGHT DIES AT ONCE")
	story.text="The reader swallows the ticket. Every light on the midway dies at once.\n\nThe gate opens.\n\nBehind you, something enormous laughs in the dark."; update_hud(); impact_flash("CLICK", Color(0.68,0.95,0.18,1)); clear_choices(); add_choice("LEAVE CARNIVAL OF CARNAGE",level_complete)

func force_exit() -> void:
	health=max(0,health-15); resolve=max(0,resolve-10); morality["violence"]+=1; record("level_exit","forced"); set_scene("PULL")
	story.text="You wrap both hands around the bars and pull. Metal screams. Something pulls back from the other side—but this time you refuse to let go.\n\nThe lock tears free.\n\n[b]Health -15. Resolve -10.[/b]"; rumble(.55,1.0,.4); impact_flash("TEAR IT OPEN", Color(0.95,0.08,0.22,1)); update_hud(); clear_choices(); add_choice("STUMBLE THROUGH",level_complete)

func turn_back() -> void:
	resolve=max(0,resolve-5); record("level_exit","turned_back"); set_scene("EVERYBODY IS LOOKING AT YOU")
	story.text="You turn toward the midway. For one second, every carnival worker is staring directly at you.\n\nThen the ticket reader spits out a black paper pass.\n\n[b]Resolve -5. Ticket +1.[/b]"; tickets+=1; update_hud(); clear_choices(); add_choice("USE THE BLACK PASS",use_ticket)

func level_complete() -> void:
	current_context="complete"; title.text="CARNIVAL OF CARNAGE — COMPLETE"; set_scene("DAWN // THE CARNIVAL IS GONE"); set_card_shell(false)
	var judgment := carnival_judgment()
	story.text="[center]Dawn has begun over %s.\n\nYou made it out, %s.\n\n[b]%s[/b]\n\nThe carnival is gone. In your pocket is a card you don't remember taking. On its back:\n\n[i]THE DARK CARNIVAL REMEMBERS.[/i]\n\nHealth %d • Resolve %d • Cash $%d • Faygo %d\nChoices remembered: %d\n\n[b]LEVEL 1 COMPLETE[/b][/center]" % [town,player_name,judgment,health,resolve,cash,faygo,history.size()]
	impact_flash("REMEMBERED", Color(0.72,0.12,0.9,1)); clear_choices(); add_choice("PLAY CARNIVAL OF CARNAGE AGAIN",reset_game)

func carnival_judgment() -> String:
	if morality["cruelty"]>=2: return "The midway liked what it saw in you."
	if morality["mercy"]+morality["sacrifice"]>=3: return "You left with more of yourself than the Carnival expected."
	if morality["violence"]>=3: return "You survived by hitting the Carnival harder than it hit you."
	if morality["honesty"]<0: return "You cheated the Carnival. It seems almost proud."
	return "You survived without showing the Carnival exactly who you are."

func reset_game() -> void:
	health=100; resolve=100; cash=60; food=3; faygo=2; tickets=0; history.clear()
	for key in morality.keys(): morality[key]=0
	town=""; player_name=""; input.text=""; show_town_prompt()

func record(event_name:String, choice:String) -> void:
	history.append({"event":event_name,"choice":choice,"health":health,"resolve":resolve,"cash":cash,"faygo":faygo,"tickets":tickets})

func update_hud(show_stats:=true) -> void:
	hud.visible=show_stats; hud.text="HEALTH %d   RESOLVE %d   CASH $%d   FOOD %d   FAYGO %d   TICKETS %d" % [health,resolve,cash,food,faygo,tickets]

func set_scene(label_text:String) -> void:
	scene_label.text = label_text
	scene_label.modulate.a = 0.45
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(scene_label, "modulate:a", 1.0, 0.16)

func set_card_shell(visible_state:bool, hint:String="") -> void:
	card_hand.visible = visible_state
	if visible_state and not hint.is_empty(): card_hint.text = hint

func impact_flash(caption:String, tint:Color) -> void:
	if transition_fx.has_method("impact"): transition_fx.call("impact", caption, tint)
	panel_punch()

func panel_punch() -> void:
	comic_frame.pivot_offset = comic_frame.size * 0.5
	comic_frame.scale = Vector2(0.982, 1.018)
	comic_frame.rotation = deg_to_rad(-0.45)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(comic_frame, "scale", Vector2.ONE, 0.18)
	tween.parallel().tween_property(comic_frame, "rotation", 0.0, 0.18)

func clear_choices() -> void:
	for child in choices.get_children(): child.queue_free()
	call_deferred("focus_first_choice")

func add_choice(label:String, callback:Callable) -> void:
	var b:=Button.new(); b.text=label; b.custom_minimum_size.y=46; b.focus_mode=Control.FOCUS_ALL; b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	apply_choice_style(b)
	b.pressed.connect(callback); choices.add_child(b)

func apply_choice_style(button:Button) -> void:
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color(0.93,0.91,0.86,1))
	button.add_theme_color_override("font_focus_color", Color(0.08,0.08,0.08,1))
	button.add_theme_color_override("font_hover_color", Color(0.75,1,0.2,1))
	button.add_theme_stylebox_override("normal", make_choice_style(Color(0.035,0.025,0.05,0.98), Color(0.32,0.16,0.48,0.9), 2))
	button.add_theme_stylebox_override("hover", make_choice_style(Color(0.07,0.03,0.09,1), Color(0.98,0.15,0.55,1), 2))
	button.add_theme_stylebox_override("focus", make_choice_style(Color(0.72,1,0.18,1), Color(0.98,0.15,0.55,1), 3))
	button.add_theme_stylebox_override("pressed", make_choice_style(Color(0.12,0.75,0.78,1), Color(0.98,0.15,0.55,1), 3))

func make_choice_style(bg:Color, border:Color, width:int) -> StyleBoxFlat:
	var style:=StyleBoxFlat.new()
	style.bg_color=bg; style.border_color=border
	style.border_width_left=width; style.border_width_top=width; style.border_width_right=width; style.border_width_bottom=width
	style.corner_radius_top_left=3; style.corner_radius_top_right=3; style.corner_radius_bottom_left=3; style.corner_radius_bottom_right=3
	style.content_margin_left=14; style.content_margin_right=14; style.content_margin_top=8; style.content_margin_bottom=8
	return style

func focus_first_choice() -> void:
	var buttons:Array[Button]=[]; collect_buttons(choices,buttons)
	if not buttons.is_empty(): buttons[0].grab_focus()

func collect_buttons(node:Node, output:Array[Button]) -> void:
	for child in node.get_children():
		if child is Button and child.visible and not child.disabled: output.append(child)
		collect_buttons(child,output)

func focus_step(direction:int) -> void:
	var buttons:Array[Button]=[]; collect_buttons(choices,buttons)
	if buttons.is_empty(): return
	var focused:=get_viewport().gui_get_focus_owner(); var index:=buttons.find(focused)
	if index<0: index=0
	else: index=wrapi(index+direction,0,buttons.size())
	buttons[index].grab_focus()

func controller_back() -> void:
	if virtual_keyboard_open:
		virtual_keyboard_open=false
		if text_entry_stage=="town": show_town_prompt()
		else: show_name_prompt()
	elif current_context=="card_hand":
		thief_resume()
	elif current_context=="name_entry":
		input.text=""; town=""; show_town_prompt()

func rumble(weak:float=.25,strong:float=.55,duration:float=.18) -> void:
	if Input.get_connected_joypads().has(last_controller_device): Input.start_joy_vibration(last_controller_device,weak,strong,duration)
