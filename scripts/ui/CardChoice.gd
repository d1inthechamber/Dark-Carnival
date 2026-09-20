extends Button

var card_name := ""
var description_text := ""
var accent := Color(0.95, 0.15, 0.55, 1.0)
var icon_texture: Texture2D
var slot_index := 0
var rest_rotation := 0.0
var motion_tween: Tween
var idle_tween: Tween

const PAPER := Color(0.80, 0.74, 0.62, 1.0)
const PAPER_DARK := Color(0.44, 0.37, 0.29, 1.0)
const INK := Color(0.018, 0.014, 0.02, 1.0)
const INK_SOFT := Color(0.055, 0.035, 0.065, 1.0)

func configure(new_name:String, new_description:String, new_accent:Color, new_icon:Texture2D, index:int) -> void:
	card_name = new_name
	description_text = new_description
	accent = new_accent
	icon_texture = new_icon
	slot_index = index
	var tilts := [-1.35, 0.5, -0.65, 1.05]
	rest_rotation = tilts[index % tilts.size()]
	rotation_degrees = rest_rotation
	queue_redraw()

func _ready() -> void:
	flat = true
	text = ""
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pivot_offset = size * 0.5
	resized.connect(_refresh_pivot)
	focus_entered.connect(_lift)
	focus_exited.connect(_settle)
	mouse_entered.connect(_mouse_focus)
	pressed.connect(_press_kick)
	call_deferred("_start_idle")
	queue_redraw()

func _refresh_pivot() -> void:
	pivot_offset = size * 0.5
	queue_redraw()

func _mouse_focus() -> void:
	grab_focus()

func _start_idle() -> void:
	if idle_tween and idle_tween.is_running():
		idle_tween.kill()
	var drift := 1.2 + float(slot_index) * 0.15
	idle_tween = create_tween().set_loops()
	idle_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.tween_property(self, "position:y", position.y - drift, 1.8 + slot_index * 0.12)
	idle_tween.tween_property(self, "position:y", position.y + drift, 1.8 + slot_index * 0.12)

func _lift() -> void:
	if idle_tween and idle_tween.is_running():
		idle_tween.pause()
	z_index = 8
	_tween_pose(Vector2(1.07, 1.07), 0.0, Vector2(0, -9))
	queue_redraw()

func _settle() -> void:
	z_index = 0
	_tween_pose(Vector2.ONE, rest_rotation, Vector2.ZERO)
	if idle_tween:
		idle_tween.play()
	queue_redraw()

func _press_kick() -> void:
	if motion_tween and motion_tween.is_running():
		motion_tween.kill()
	scale = Vector2(0.95, 1.04)
	rotation_degrees = 0.0
	motion_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	motion_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.10)

func _tween_pose(target_scale:Vector2, target_rotation:float, target_offset:Vector2) -> void:
	if motion_tween and motion_tween.is_running():
		motion_tween.kill()
	motion_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	motion_tween.tween_property(self, "scale", target_scale, 0.14)
	motion_tween.parallel().tween_property(self, "rotation_degrees", target_rotation, 0.14)
	motion_tween.parallel().tween_property(self, "pivot_offset", size * 0.5 + target_offset, 0.14)

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var inner := rect.grow(-5)
	var art_rect := Rect2(13, 35, maxf(30.0, size.x - 26.0), maxf(56.0, size.y - 87.0))
	var info_rect := Rect2(8, size.y - 44, maxf(30.0, size.x - 16.0), 36)
	var font := ThemeDB.fallback_font
	var title_size := 18
	var body_size := 11

	draw_rect(rect, PAPER_DARK, true)
	draw_rect(inner, INK, true)
	draw_rect(inner, accent.darkened(0.28), false, 3.0)
	draw_line(Vector2(10, 29), Vector2(size.x - 10, 29), accent, 2.0)

	for i in range(7):
		var x := 12.0 + float(i) * 33.0 + float(slot_index * 4)
		draw_line(Vector2(x, 41), Vector2(x - 26, art_rect.end.y - 4), Color(1,1,1,0.05), 1.0)
		draw_line(Vector2(x + 12, 44), Vector2(x + 37, art_rect.end.y - 7), Color(accent.r,accent.g,accent.b,0.08), 1.0)
	for i in range(3):
		var y := 48.0 + float(i) * 28.0
		draw_line(Vector2(19,y), Vector2(size.x-17,y+8), Color(0,0,0,0.35), 2.0)

	draw_rect(art_rect, INK_SOFT, true)
	draw_rect(art_rect, accent.darkened(0.38), false, 2.0)

	if icon_texture:
		var icon_rect := art_rect.grow(-5)
		draw_texture_rect(icon_texture, icon_rect, false, Color(1,1,1,0.98))

	draw_rect(info_rect, PAPER, true)
	draw_rect(info_rect, Color(0.05,0.035,0.04,1), false, 2.0)

	var roman := ["I", "II", "III", "IV"][slot_index % 4]
	draw_string(font, Vector2(12, 22), roman, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER)
	draw_string(font, Vector2(36, 23), card_name, HORIZONTAL_ALIGNMENT_LEFT, size.x - 48, title_size, accent)

	var lines := _wrap_description(description_text.to_upper(), 31)
	if not lines.is_empty():
		draw_string(font, Vector2(14, size.y - 26), lines[0], HORIZONTAL_ALIGNMENT_LEFT, size.x - 28, body_size, Color(0.08,0.055,0.05,1))
	if lines.size() > 1:
		draw_string(font, Vector2(14, size.y - 13), lines[1], HORIZONTAL_ALIGNMENT_LEFT, size.x - 28, body_size, Color(0.08,0.055,0.05,1))

	draw_circle(Vector2(size.x - 17, 16), 5.0, Color(accent.r,accent.g,accent.b,0.88))
	draw_circle(Vector2(16, size.y - 16), 4.0, Color(0.03,0.02,0.025,0.9))
	draw_line(Vector2(4, 12), Vector2(18, 4), PAPER, 2.0)
	draw_line(Vector2(size.x-18, size.y-4), Vector2(size.x-4, size.y-14), PAPER, 2.0)

	if has_focus():
		draw_rect(rect.grow(-1), Color(0.98,0.93,0.78,1), false, 3.0)
		draw_line(Vector2(5,5), Vector2(34,5), accent, 5.0)
		draw_line(Vector2(5,5), Vector2(5,34), accent, 5.0)
		draw_line(Vector2(size.x-5,size.y-5), Vector2(size.x-34,size.y-5), accent, 5.0)
		draw_line(Vector2(size.x-5,size.y-5), Vector2(size.x-5,size.y-34), accent, 5.0)

func _wrap_description(value:String, max_chars:int) -> Array[String]:
	var words := value.split(" ")
	var lines:Array[String] = [""]
	for word in words:
		var candidate := word if lines[-1].is_empty() else lines[-1] + " " + word
		if candidate.length() > max_chars and not lines[-1].is_empty():
			lines.append(word)
		else:
			lines[-1] = candidate
		if lines.size() >= 2 and lines[-1].length() >= max_chars - 5:
			break
	return lines
