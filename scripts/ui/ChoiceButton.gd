extends Button

var accent := Color(0.72, 1.0, 0.18, 1.0)
var rest_rotation := 0.0
var motion_tween: Tween

func configure(index:int, new_accent:Color = Color(0.72, 1.0, 0.18, 1.0)) -> void:
	accent = new_accent
	var tilts := [-0.28, 0.18, -0.12, 0.24]
	rest_rotation = tilts[index % tilts.size()]
	rotation_degrees = rest_rotation
	queue_redraw()

func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pivot_offset = size * 0.5
	resized.connect(_refresh_pivot)
	focus_entered.connect(_focus_in)
	focus_exited.connect(_focus_out)
	mouse_entered.connect(grab_focus)
	pressed.connect(_press)
	queue_redraw()

func _refresh_pivot() -> void:
	pivot_offset = size * 0.5
	queue_redraw()

func _focus_in() -> void:
	z_index = 5
	_tween_pose(Vector2(1.018, 1.018), 0.0, Vector2(8, 0))
	queue_redraw()

func _focus_out() -> void:
	z_index = 0
	_tween_pose(Vector2.ONE, rest_rotation, Vector2.ZERO)
	queue_redraw()

func _press() -> void:
	if motion_tween and motion_tween.is_running():
		motion_tween.kill()
	scale = Vector2(0.985, 0.95)
	motion_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	motion_tween.tween_property(self, "scale", Vector2(1.02, 1.02), 0.08)

func _tween_pose(target_scale:Vector2, target_rotation:float, offset:Vector2) -> void:
	if motion_tween and motion_tween.is_running():
		motion_tween.kill()
	motion_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	motion_tween.tween_property(self, "scale", target_scale, 0.12)
	motion_tween.parallel().tween_property(self, "rotation_degrees", target_rotation, 0.12)
	motion_tween.parallel().tween_property(self, "pivot_offset", size * 0.5 - offset, 0.12)

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var ink := Color(0.018, 0.012, 0.024, 0.98)
	var paper := Color(0.77, 0.70, 0.57, 0.28)
	draw_rect(r, ink, true)
	draw_line(Vector2(2,2), Vector2(size.x-14,2), Color(accent.r,accent.g,accent.b,0.55), 2.0)
	draw_line(Vector2(2,size.y-3), Vector2(size.x-28,size.y-3), paper, 1.0)
	for i in range(4):
		var y := 10.0 + float(i) * 9.0
		draw_line(Vector2(10,y), Vector2(size.x-12,y+4), Color(1,1,1,0.025), 1.0)
	if has_focus():
		draw_rect(r.grow(-1), Color(0.96,0.92,0.78,1), false, 2.0)
		draw_rect(Rect2(0,0,6,size.y), accent, true)
