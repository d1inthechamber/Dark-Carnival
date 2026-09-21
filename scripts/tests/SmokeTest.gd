extends SceneTree

var failures:Array[String] = []

func _initialize() -> void:
	call_deferred("_run")

func _assert(condition:bool, message:String) -> void:
	if not condition:
		failures.append(message)
		push_error("SMOKE TEST: " + message)

func _fresh_game() -> Node:
	var packed := load("res://scenes/Main.tscn") as PackedScene
	var game := packed.instantiate()
	root.add_child(game)
	return game

func _discard(game:Node) -> void:
	game.queue_free()
	await process_frame
	await process_frame

func _setup_player(game:Node) -> void:
	await process_frame
	game.call("show_town_prompt")
	await process_frame
	var input:LineEdit = game.get_node("Margin/VBox/Input")
	input.text = "Test Town"
	game.call("submit_town")
	await process_frame
	input.text = "Tester"
	game.call("submit_name")
	await process_frame

func _run() -> void:
	print("Dark Carnival regression smoke test starting...")

	# Path 1: fair midway route through a ticket exit.
	var game := _fresh_game()
	await _setup_player(game)
	_assert(game.get("current_context") == "gate", "player setup should reach gate")
	game.call("thief_event")
	_assert(game.get("cash") == 40, "pickpocket should remove $20")
	game.call("let_thief_go")
	game.call("bottle_game")
	game.call("play_bottles")
	_assert(game.get("tickets") == 1, "fair bottle game should award a ticket")
	game.call("mirror_tent")
	game.call("mirror_trust")
	game.call("finale_gate")
	game.call("use_ticket")
	game.call("level_complete")
	_assert(game.get("current_context") == "complete", "ticket path should complete the level")
	await _discard(game)

	# Path 2: Hatchet card restores stolen cash and records violence.
	game = _fresh_game()
	await _setup_player(game)
	game.call("thief_event")
	game.call("play_card", "HATCHET")
	_assert(game.get("cash") == 60, "Hatchet should recover stolen cash")
	var morality:Dictionary = game.get("morality")
	_assert(int(morality["violence"]) >= 1, "Hatchet should increase violence")
	await _discard(game)

	# Path 3: Faygo Break spends Faygo and restores resolve without leaving the encounter.
	game = _fresh_game()
	await _setup_player(game)
	game.set("resolve", 60)
	game.call("thief_event")
	game.call("play_card", "FAYGO BREAK")
	_assert(game.get("faygo") == 1, "Faygo Break should spend one Faygo")
	_assert(game.get("resolve") == 80, "Faygo Break should restore 20 Resolve")
	_assert(game.get("current_context") == "thief_resume", "Faygo Break should return to the thief decision")
	await _discard(game)

	# Path 4: Back Door exits the pickpocket encounter at a resolve/honesty cost.
	game = _fresh_game()
	await _setup_player(game)
	game.call("thief_event")
	game.call("play_card", "BACK DOOR")
	_assert(game.get("resolve") == 92, "Back Door should cost 8 Resolve")
	morality = game.get("morality")
	_assert(int(morality["honesty"]) == -1, "Back Door should reduce honesty")
	_assert(game.get("current_context") == "crossroads", "Back Door should escape to the midway crossroads")
	await _discard(game)

	# Path 5: mirror Faygo bargain and force-exit route both remain viable.
	game = _fresh_game()
	await _setup_player(game)
	game.call("mirror_tent")
	game.call("mirror_faygo")
	_assert(game.get("faygo") == 1, "mirror bargain should consume Faygo")
	game.call("finale_gate")
	game.call("force_exit")
	game.call("level_complete")
	_assert(game.get("current_context") == "complete", "force-exit path should complete the level")
	await _discard(game)

	if failures.is_empty():
		print("Dark Carnival regression smoke test PASSED")
		quit(0)
	else:
		print("Dark Carnival regression smoke test FAILED: %d issue(s)" % failures.size())
		for item in failures:
			print(" - " + item)
		quit(1)
