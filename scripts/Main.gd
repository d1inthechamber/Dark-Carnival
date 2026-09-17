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
	story.text = "[center]Something wicked has come to town.\n\nSometime after midnight, trucks began rolling in. By morning, an enormous carnival stood where yesterday there was nothing.\n\nNobody remembers seeing it arrive.\n\n[b]Where are you?[/b][/center]"
	input.visible = true; input.placeholder_text = "Enter your town"
	clear_choices(); add_choice("CONTINUE", submit_town); add_choice("CONTROLLER KEYBOARD", func(): open_virtual_keyboard("town")); update_hud(false)

func show_name_prompt() -> void:
	current_context = "name_entry"; text_entry_stage = "name"; virtual_keyboard_open = false
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
	text_entry_stage = stage; virtual_keyboard_open = true; current_context = stage + "_keyboard"; clear_choices()
	var grid := GridContainer.new(); grid.columns = 7; grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL; choices.add_child(grid)
	var keys: Array[String] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9","-","'",".","SPACE","BACK","DONE"]
	for key_text in keys:
		var b := Button.new(); b.text = key_text; b.custom_minimum_size = Vector2(90,44); b.focus_mode = Control.FOCUS_ALL
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
	current_context = "gate"; title.text = "CARNIVAL OF CARNAGE — THE GATES"
	story.text = "The midway glows against the night over %s. A clown silently waves you through.\n\nThe instant you cross the threshold—\n\n[b]CLANG.[/b]\n\nThe iron gates lock behind you." % town
	clear_choices(); add_choice("Ask the clown about the gate", gate_clown); add_choice("Try to force the gate open", gate_force); add_choice("Enter the midway", thief_event); update_hud(); rumble(.15,.45,.16)

func gate_clown() -> void:
	story.text = "The clown's painted smile doesn't move. He points toward the midway.\n\n\"Everybody gets out eventually.\""; clear_choices(); add_choice("Enter the midway", thief_event)

func gate_force() -> void:
	resolve = max(0,resolve-5); record("locked_gate","tried_to_escape"); story.text = "The gate doesn't move. Something on the other side seems to pull back.\n\n[b]Resolve -5[/b]"; clear_choices(); add_choice("Enter the midway", thief_event); update_hud(); rumble(.35,.7,.22)

func thief_event() -> void:
	current_context = "thief"; cash = max(0,cash-20)
	story.text = "A teenager slams into your shoulder and vanishes into the crowd.\n\n[b]$20 is gone.[/b]\n\nA battered card case at your belt flips open. The Carnival is offering another way."
	clear_choices(); add_choice("CHASE HIM", chase_thief); add_choice("LET HIM GO", let_thief_go); add_choice("CALL FOR HELP", call_for_help); add_choice("PLAY A CARD", open_card_hand); update_hud()

func open_card_hand() -> void:
	current_context = "card_hand"; story.text = "[center][b]YOUR HAND[/b]\n\nCards resolve immediately. Some solve problems. Some change what kind of problem you have.\n\n[i]D-pad/stick selects • A/Cross plays • B/Circle backs out • LB/RB cycles[/i][/center]"; clear_choices()
	for card_name in deck: add_choice(card_name + " — " + card_description(card_name), func(): play_card(card_name))
	add_choice("PUT THE CARDS AWAY", thief_resume)

func card_description(card_name: String) -> String:
	match card_name:
		"HATCHET": return "recover cash; violence rises"
		"FAYGO BREAK": return "spend 1 Faygo; restore Resolve"
		"CARNIVAL SIGHT": return "reveal the danger behind CALL FOR HELP"
		"BACK DOOR": return "escape encounter; lose Resolve"
	return "unknown"

func play_card(card_name: String) -> void:
	record("pickpocket_card",card_name)
	match card_name:
		"HATCHET":
			cash += 20; morality["violence"] += 1; story.text = "The HATCHET card snaps forward like a thrown blade. The thief drops the money and runs.\n\n[b]Cash recovered. Violence remembered.[/b]"; rumble(.45,.9,.28); midway_crossroads()
		"FAYGO BREAK":
			if faygo <= 0: story.text = "You reach for a bottle. Empty."; clear_choices(); add_choice("BACK",open_card_hand); return
			faygo -= 1; resolve = min(100,resolve+20); current_context = "thief_resume"; story.text = "You crack a cold Faygo. The midway noise briefly becomes music.\n\n[b]Faygo -1. Resolve +20.[/b]"; thief_choices(); update_hud()
		"CARNIVAL SIGHT":
			resolve = max(0,resolve-3); current_context = "thief_resume"; story.text = "The card's eye opens. You see CALL FOR HELP before choosing it: a worker catches the kid... and keeps hitting him after the money is recovered.\n\n[b]Resolve -3.[/b]"; thief_choices(); update_hud()
		"BACK DOOR":
			resolve = max(0,resolve-8); morality["honesty"] -= 1; story.text = "A painted door appears. You step through and emerge two tents away. The thief—and your money—are gone.\n\n[b]Resolve -8.[/b]"; midway_crossroads()

func thief_resume() -> void:
	current_context = "thief_resume"; story.text = "The thief is still somewhere in the crowd. Your $20 is still gone."; thief_choices()

func thief_choices() -> void:
	clear_choices(); add_choice("CHASE HIM",chase_thief); add_choice("LET HIM GO",let_thief_go); add_choice("CALL FOR HELP",call_for_help); add_choice("PLAY A CARD",open_card_hand)

func chase_thief() -> void:
	health = max(0,health-8); cash += 20; morality["violence"] += 1; record("pickpocket","chased"); story.text = "You catch him between two tents. You recover the money but leave bleeding.\n\n[b]Cash recovered. Health -8.[/b]"; rumble(.4,.65,.24); midway_crossroads()

func let_thief_go() -> void:
	morality["mercy"] += 1; record("pickpocket","let_go"); story.text = "You watch him disappear. Somewhere beyond the lights, a calliope plays a tune you almost recognize."; midway_crossroads()

func call_for_help() -> void:
	story.text = "A huge carnival worker catches the kid and retrieves your money—then knocks him down and keeps hitting him.\n\n\"This what you wanted?\""; clear_choices(); add_choice("STOP THE WORKER",stop_worker); add_choice("Take your money and leave",take_money); add_choice("Watch",watch_worker); add_choice("Help the worker",help_worker)

func stop_worker() -> void:
	cash += 20; health=max(0,health-10); morality["mercy"]+=2; morality["sacrifice"]+=1; record("worker","intervened"); story.text="You step between them. The worker shoves you hard, but backs away.\n\n[b]Cash recovered. Health -10.[/b]"; midway_crossroads()
func take_money() -> void:
	cash+=20; morality["greed"]+=1; record("worker","took_money"); story.text="You take the crumpled bills and walk away. The sounds behind you continue too long."; midway_crossroads()
func watch_worker() -> void:
	resolve=max(0,resolve-10); morality["cruelty"]+=1; record("worker","watched"); story.text="You do nothing. The worker eventually stops and smiles as though you share a secret.\n\n[b]Resolve -10.[/b]"; midway_crossroads()
func help_worker() -> void:
	cash+=20; morality["violence"]+=2; morality["cruelty"]+=2; record("worker","joined"); story.text="For a few terrible seconds, you join in. The worker hands back your money.\n\n\"Carnival remembers its friends.\""; midway_crossroads()

func midway_crossroads() -> void:
	current_context="crossroads"; update_hud(); clear_choices(); add_choice("CONTINUE TO THE MIDWAY",bottle_game)

func bottle_game() -> void:
	current_context="bottles"; title.text="CARNIVAL OF CARNAGE — THE MIDWAY"
	story.text="A booth operator taps three milk bottles with a cane.\n\n\"Three throws. Ten bucks. Knock 'em down and I'll give you a ticket.\"\n\nBehind him, a small girl watches a stuffed rabbit hanging from the prize rack."
	clear_choices(); add_choice("PAY $10 AND PLAY",play_bottles); add_choice("CHEAT WHILE HE LOOKS AWAY",cheat_bottles); add_choice("BUY THE GIRL A PRIZE — $15",buy_prize); add_choice("KEEP WALKING",mirror_tent)

func play_bottles() -> void:
	if cash < 10: story.text="You check your pockets. Not enough."; clear_choices(); add_choice("KEEP WALKING",mirror_tent); return
	cash-=10; tickets+=1; morality["honesty"]+=1; record("bottle_game","played_fair"); story.text="The first throw misses. The second clips the top bottle. The third sends all three crashing down.\n\nThe operator's grin vanishes.\n\n[b]Ticket +1. Cash -$10.[/b]"; update_hud(); clear_choices(); add_choice("MOVE ON",mirror_tent)

func cheat_bottles() -> void:
	tickets+=1; morality["honesty"]-=2; morality["greed"]+=1; record("bottle_game","cheated"); story.text="While the operator turns, you kick the hidden brace beneath the counter. One throw topples everything.\n\nHe knows. He gives you the ticket anyway.\n\n[b]Ticket +1. The Carnival noticed.[/b]"; update_hud(); clear_choices(); add_choice("MOVE ON",mirror_tent)

func buy_prize() -> void:
	if cash < 15: story.text="You cannot afford it."; clear_choices(); add_choice("KEEP WALKING",mirror_tent); return
	cash-=15; morality["mercy"]+=1; morality["sacrifice"]+=1; record("bottle_game","gifted_prize"); story.text="You buy the rabbit and hand it to the girl. She hugs it, then presses a paper ticket into your palm.\n\n\"I found this. You need it more.\"\n\n[b]Cash -$15. Ticket +1.[/b]"; tickets+=1; update_hud(); clear_choices(); add_choice("MOVE ON",mirror_tent)

func mirror_tent() -> void:
	current_context="mirrors"; title.text="CARNIVAL OF CARNAGE — MIRROR MAZE"
	story.text="The midway narrows into a tent of warped mirrors. Every reflection is you—but each one made a different choice tonight.\n\nOne reflection knocks from inside the glass.\n\n\"Trade me something real and I'll show you the exit.\""
	clear_choices(); add_choice("GIVE UP 1 FAYGO",mirror_faygo); add_choice("BREAK THE MIRROR",mirror_break); add_choice("TRUST YOURSELF",mirror_trust)

func mirror_faygo() -> void:
	if faygo<=0: story.text="You have no Faygo to offer."; clear_choices(); add_choice("BREAK THE MIRROR",mirror_break); add_choice("TRUST YOURSELF",mirror_trust); return
	faygo-=1; resolve=min(100,resolve+10); record("mirror_maze","paid_reflection"); story.text="The bottle vanishes through the glass. Your reflection drinks, smiles, and points to a seam in the darkness.\n\n[b]Faygo -1. Resolve +10.[/b]"; update_hud(); clear_choices(); add_choice("FOLLOW THE EXIT",finale_gate)

func mirror_break() -> void:
	health=max(0,health-12); morality["violence"]+=1; record("mirror_maze","broke_mirror"); story.text="You smash through. Glass bites your hands, but cold night air waits beyond the last pane.\n\n[b]Health -12.[/b]"; rumble(.45,.8,.25); update_hud(); clear_choices(); add_choice("CLIMB THROUGH",finale_gate)

func mirror_trust() -> void:
	var penalty := 8
	if morality["honesty"] >= 1 or morality["mercy"] >= 2: penalty=0
	resolve=max(0,resolve-penalty); record("mirror_maze","trusted_self")
	if penalty==0: story.text="You stop watching the reflections and listen to your own footsteps. The false paths go silent. You find the exit untouched."
	else: story.text="You wander until the reflections begin whispering your name. Eventually you find the exit.\n\n[b]Resolve -8.[/b]"
	update_hud(); clear_choices(); add_choice("STEP OUTSIDE",finale_gate)

func finale_gate() -> void:
	current_context="finale"; title.text="CARNIVAL OF CARNAGE — LAST CALL"
	story.text="You emerge behind the midway. The locked entrance gate stands ahead. A brass ticket reader blinks beside it.\n\nAbove you, loudspeakers crackle.\n\n\"ONE SOUL. ONE NIGHT. ONE WAY OUT.\""
	clear_choices()
	if tickets>0: add_choice("INSERT A TICKET",use_ticket)
	add_choice("FORCE THE EXIT",force_exit)
	add_choice("TURN BACK TOWARD THE CARNIVAL",turn_back)

func use_ticket() -> void:
	tickets-=1; record("level_exit","ticket"); story.text="The reader swallows the ticket. Every light on the midway dies at once.\n\nThe gate opens.\n\nBehind you, something enormous laughs in the dark."; update_hud(); clear_choices(); add_choice("LEAVE CARNIVAL OF CARNAGE",level_complete)

func force_exit() -> void:
	health=max(0,health-15); resolve=max(0,resolve-10); morality["violence"]+=1; record("level_exit","forced"); story.text="You wrap both hands around the bars and pull. Metal screams. Something pulls back from the other side—but this time you refuse to let go.\n\nThe lock tears free.\n\n[b]Health -15. Resolve -10.[/b]"; rumble(.55,1.0,.4); update_hud(); clear_choices(); add_choice("STUMBLE THROUGH",level_complete)

func turn_back() -> void:
	resolve=max(0,resolve-5); record("level_exit","turned_back"); story.text="You turn toward the midway. For one second, every carnival worker is staring directly at you.\n\nThen the ticket reader spits out a black paper pass.\n\n[b]Resolve -5. Ticket +1.[/b]"; tickets+=1; update_hud(); clear_choices(); add_choice("USE THE BLACK PASS",use_ticket)

func level_complete() -> void:
	current_context="complete"; title.text="CARNIVAL OF CARNAGE — COMPLETE"
	var judgment := carnival_judgment()
	story.text="[center]Dawn has begun over %s.\n\nYou made it out, %s.\n\n[b]%s[/b]\n\nThe carnival is gone. In your pocket is a card you don't remember taking. On its back:\n\n[i]THE DARK CARNIVAL REMEMBERS.[/i]\n\nHealth %d • Resolve %d • Cash $%d • Faygo %d\nChoices remembered: %d\n\n[b]LEVEL 1 COMPLETE[/b][/center]" % [town,player_name,judgment,health,resolve,cash,faygo,history.size()]
	clear_choices(); add_choice("PLAY CARNIVAL OF CARNAGE AGAIN",reset_game)

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
	history.append({"event":event_name,"choice":choice,"health":health,"resolve":resolve,"cash":cash})

func update_hud(show_stats:=true) -> void:
	hud.visible=show_stats; hud.text="HEALTH %d   RESOLVE %d   CASH $%d   FOOD %d   FAYGO %d   TICKETS %d" % [health,resolve,cash,food,faygo,tickets]

func clear_choices() -> void:
	for child in choices.get_children(): child.queue_free()
	call_deferred("focus_first_choice")

func add_choice(label:String, callback:Callable) -> void:
	var b:=Button.new(); b.text=label; b.custom_minimum_size.y=44; b.focus_mode=Control.FOCUS_ALL; b.pressed.connect(callback); choices.add_child(b)

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
	elif current_context=="card_hand": thief_resume()
	elif current_context=="name_entry": input.text=""; town=""; show_town_prompt()

func rumble(weak:float=.25,strong:float=.55,duration:float=.18) -> void:
	if Input.get_connected_joypads().has(last_controller_device): Input.start_joy_vibration(last_controller_device,weak,strong,duration)
