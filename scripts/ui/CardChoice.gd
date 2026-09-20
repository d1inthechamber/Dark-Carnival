extends Button

var card_name := ""
var description_text := ""
var accent := Color(0.95, 0.15, 0.55, 1.0)
var icon_texture: Texture2D
var slot_index := 0
var rest_rotation := 0.0
var motion_tween: Tween

const PAPER := Color(0.76, 0.70, 0.58, 1.0)
const PAPER_DARK := Color(0.46, 0.40, 0.32, 1.0)
const INK := Color(0.025, 0.018, 0.025, 1.0)
const INK_SOFT := Color(0.08, 0.055, 0.075, 1.0)

func configure(new_name:String, new_description:String, new_accent:Color, new_icon:Texture2D, index:int) -> void:
	card_name = new_name
	description_text = new_description
	accent = new_accent
	icon_texture = new_icon
	slot_index = index
	var tilts := [-1.1, 0.45, -0.55, 0.9]
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
	queue_redraw()

func _refresh_pivot() -> void:
	pivot_offset = size * 0.5
	queue_redraw()

func _mouse_focus() -> void:
	grab_focus()

func _lift() -> void:
	_tween_pose(Vector2(1.055, 1.055), 0.0, Vector2(0, -7))
	queue_redraw()

func _settle() -> void:
	_tween_pose(Vector2.ONE, rest_rotation, Vector2.ZERO)
	queue_redraw()

func _press_kick() -> void:
	if motion_tween and motion_tween.is_running():
		motion_tween.kill()
	scale = Vector2(0.95, 1.04)
	rotation_degrees = 0.0
	motion_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	motion_tween.tween_property(self, "scale", Vector2(1.04, 1.04), 0.11)

func _tween_pose(target_scale:Vector2, target_rotation:float, target_position:Vector2) -> void:
	if motion_tween and motion_tween.is_running():
		motion_tween.kill()
	motion_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	motion_tween.tween_property(self, "scale", target_scale, 0.13)
	motion_tween.parallel().tween_property(self, "rotation_degrees", target_rotation, 0.13)
	motion_tween.parallel().tween_property(self, "position:y", target_position.y, 0.13)

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var inner := rect.grow(-4)
	var art_rect := Rect2(13, 34, maxf(20.0, size.x - 26.0), maxf(38.0, size.y - 82.0))
	var info_rect := Rect2(8, size.y - 42, maxf(20.0, size.x - 16.0), 34)
	var font := ThemeDB.fallback_font
	var title_size := 18
	var body_size := 11

	# Dirty paper rim and deep-ink card face.
	draw_rect(rect, PAPER_DARK, true)
	draw_rect(inner, INK, true)
	draw_rect(inner, accent.darkened(0.25), false, 3.0)
	draw_line(Vector2(9, 29), Vector2(size.x - 9, 29), accent, 2.0)

	# Cross-hatched scratches keep the cards feeling printed rather than glossy.
	for i in range(5):
		var x := 18.0 + float(i) * 27.0 + float(slot_index * 3)
		draw_line(Vector2(x, 39), Vector2(x - 24, art_rect.end.y - 5), Color(1,1,1,0.055), 1.0)
		draw_line(Vector2(x + 14, 42), Vector2(x + 34, art_rect.end.y - 4), Color(accent.r,accent.g,accent.b,0.075), 1.0)

	draw_rect(art_rect, INK_SOFT, true)
	draw_rect(art_rect, accent.darkened(0.45), false, 2.0)

	if icon_texture:
		var icon_rect := art_rect.grow(-9)
		draw_texture_rect(icon_texture, icon_rect, false, Color(1,1,1,0.96))

	draw_rect(info_rect, PAPER, true)
	draw_rect(info_rect, Color(0.05,0.035,0.04,1), false, 2.0)

	var roman := ["I", "II", "III", "IV"][slot_index % 4]
	draw_string(font, Vector2(12, 22), roman, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, PAPER)
	draw_string(font, Vector2(36, 23), card_name, HORIZONTAL_ALIGNMENT_LEFT, size.x - 48, title_size, accent)

	var lines := _wrap_description(description_text.to_upper(), 30)
	if not lines.is_empty():
		draw_string(font, Vector2(14, size.y - 25), lines[0], HORIZONTAL_ALIGNMENT_LEFT, size.x - 28, body_size, Color(0.08,0.055,0.05,1))
	if lines.size() > 1:
		draw_string(font, Vector2(14, size.y - 12), lines[1], HORIZONTAL_ALIGNMENT_LEFT, size.x - 28, body_size, Color(0.08,0.055,0.05,1))

	# Registration marks and focus treatment echo old offset comic printing.
	draw_circle(Vector2(size.x - 16, 16), 5.0, Color(accent.r,accent.g,accent.b,0.85))
	draw_circle(Vector2(16, size.y - 16), 4.0, Color(0.03,0.02,0.025,0.85))
	if has_focus():
		draw_rect(rect.grow(-1), Color(0.96,0.92,0.78,1), false, 3.0)
		draw_line(Vector2(5,5), Vector2(28,5), accent, 4.0)
		draw_line(Vector2(5,5), Vector2(5,28), accent, 4.0)
		draw_line(Vector2(size.x-5,size.y-5), Vector2(size.x-28,size.y-5), accent, 4.0)
		draw_line(Vector2(size.x-5,size.y-5), Vector2(size.x-5,size.y-28), accent, 4.0)

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
