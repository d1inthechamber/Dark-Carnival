extends Control

var town := ""
var player_name := ""
var health := 100
var resolve := 100
var cash := 60
var food := 3
var tickets := 0
var history: Array[Dictionary] = []
var hidden := {"mercy": 0, "greed": 0, "violence": 0, "honesty": 0, "sacrifice": 0, "cruelty": 0}

@onready var title: Label = $Margin/VBox/Title
@onready var story: RichTextLabel = $Margin/VBox/Story
@onready var input: LineEdit = $Margin/VBox/Input
@onready var choices: VBoxContainer = $Margin/VBox/Choices
@onready var hud: Label = $Margin/VBox/HUD

func _ready() -> void:
	show_town_prompt()

func show_town_prompt() -> void:
	title.text = "THE DARK CARNIVAL"
	story.text = "[center]Something wicked has come to town.\n\nSometime after midnight, trucks began rolling in. By morning, an enormous carnival stood where yesterday there was nothing.\n\nNobody remembers seeing it arrive.\n\n[b]Where are you?[/b][/center]"
	input.visible = true
	input.placeholder_text = "Enter your town"
	clear_choices()
	add_choice("CONTINUE", submit_town)
	update_hud(false)

func submit_town() -> void:
	if input.text.strip_edges().is_empty(): return
	town = input.text.strip_edges()
	input.text = ""
	input.placeholder_text = "Enter your name"
	story.text = "[center][b]WELCOME TO %s[/b]\n\nTHE DARK CARNIVAL IS NOW OPEN\n\nAdmission is free.\nLeaving may cost considerably more.\n\nWhat is your name?[/center]" % town.to_upper()
	clear_choices(); add_choice("ENTER THE MIDWAY", submit_name)

func submit_name() -> void:
	if input.text.strip_edges().is_empty(): return
	player_name = input.text.strip_edges(); input.visible = false; start_gate()

func start_gate() -> void:
	title.text = "CARNIVAL OF CARNAGE — THE GATES"
	story.text = "The midway glows against the night over %s. A clown beside the entrance silently waves you through.\n\nThe instant you cross the threshold—\n\n[b]CLANG.[/b]\n\nThe iron gates lock behind you." % town
	clear_choices(); add_choice("Ask the clown about the gate", gate_clown); add_choice("Try to force the gate open", gate_force); add_choice("Ignore it and enter the midway", thief_event); update_hud()

func gate_clown() -> void:
	story.text = "The clown's painted smile doesn't move. He points toward the midway.\n\n\"Everybody gets out eventually.\""
	clear_choices(); add_choice("Enter the midway", thief_event)

func gate_force() -> void:
	resolve = max(0, resolve - 5); record("locked_gate", "tried_to_escape", {})
	story.text = "The gate doesn't move. For a moment you swear something on the other side pulls back.\n\n[b]Resolve -5[/b]"
	clear_choices(); add_choice("Enter the midway", thief_event); update_hud()

func thief_event() -> void:
	cash = max(0, cash - 20)
	story.text = "A teenager slams into your shoulder and vanishes into the crowd.\n\nYou check your pocket.\n\n[b]$20 is gone.[/b]"
	clear_choices(); add_choice("CHASE HIM", chase_thief); add_choice("LET HIM GO", let_thief_go); add_choice("CALL FOR HELP", call_for_help); update_hud()

func chase_thief() -> void:
	health = max(0, health - 8); cash += 20; hidden["violence"] += 1; record("pickpocket", "chased", {"health_cost": 8})
	story.text = "You catch him between two tents. After a struggle, you recover the money, but leave bleeding from the elbow.\n\n[b]Cash recovered. Health -8.[/b]"; finish_slice()

func let_thief_go() -> void:
	hidden["mercy"] += 1; record("pickpocket", "let_go", {"money_lost": 20})
	story.text = "You watch him disappear. Somewhere beyond the lights, a calliope begins playing a tune you almost recognize."; finish_slice()

func call_for_help() -> void:
	story.text = "A huge carnival worker catches the kid within seconds. He retrieves your money—then knocks the teenager down and keeps hitting him.\n\nThe worker looks back at you.\n\n\"This what you wanted?\""
	clear_choices(); add_choice("STOP THE WORKER", stop_worker); add_choice("Take your money and leave", take_money); add_choice("Watch", watch_worker); add_choice("Help the worker", help_worker)

func stop_worker() -> void:
	cash += 20; health = max(0, health - 10); hidden["mercy"] += 2; hidden["sacrifice"] += 1; record("worker_beating", "intervened", {"health_cost": 10})
	story.text = "You step between them. The worker shoves you hard, but finally backs away. The kid stares at you before running into the darkness.\n\n[b]Cash recovered. Health -10.[/b]"; finish_slice()

func take_money() -> void:
	cash += 20; hidden["greed"] += 1; record("worker_beating", "took_money", {})
	story.text = "You take the crumpled bills from the pavement and walk away. The sounds behind you continue longer than you expected."; finish_slice()

func watch_worker() -> void:
	resolve = max(0, resolve - 10); hidden["cruelty"] += 1; record("worker_beating", "watched", {})
	story.text = "You do nothing. Eventually the worker stops.\n\nHe smiles at you as though the two of you now share a secret.\n\n[b]Resolve -10.[/b]"; finish_slice()

func help_worker() -> void:
	cash += 20; hidden["violence"] += 2; hidden["cruelty"] += 2; record("worker_beating", "joined", {})
	story.text = "For a few terrible seconds, you join in. When it's over, the worker hands back your money.\n\n\"Carnival remembers its friends.\""; finish_slice()

func finish_slice() -> void:
	update_hud(); clear_choices(); add_choice("CONTINUE INTO CARNIVAL OF CARNAGE", preview_map)

func preview_map() -> void:
	title.text = "THE DARK CARNIVAL"
	story.text = "[center][b]CARNIVAL OF CARNAGE[/b] — OPEN\n\nRINGMASTER — LOCKED\nRIDDLE BOX — LOCKED\nTHE GREAT MILENKO — LOCKED\nTHE AMAZING JECKEL BROTHERS — LOCKED\nTHE WRAITH — ?\n\n[i]The carnival remembers everything.[/i]\n\nBuild 0.1 vertical slice complete.[/center]"
	clear_choices(); add_choice("PLAY AGAIN", reset_game)

func reset_game() -> void:
	health = 100; resolve = 100; cash = 60; food = 3; tickets = 0; history.clear()
	for key in hidden.keys(): hidden[key] = 0
	town = ""; player_name = ""; input.text = ""; show_town_prompt()

func record(event_name: String, choice: String, context: Dictionary) -> void:
	history.append({"event": event_name, "choice": choice, "context": context})

func update_hud(show_stats := true) -> void:
	hud.visible = show_stats; hud.text = "HEALTH %d     RESOLVE %d     CASH $%d     FOOD %d     TICKETS %d" % [health, resolve, cash, food, tickets]

func clear_choices() -> void:
	for child in choices.get_children(): child.queue_free()

func add_choice(label: String, callback: Callable) -> void:
	var button := Button.new(); button.text = label; button.custom_minimum_size.y = 44; button.pressed.connect(callback); choices.add_child(button)
