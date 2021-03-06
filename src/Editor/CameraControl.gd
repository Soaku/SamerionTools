extends Node2D

const Cell = preload("res://src/AreaDisplay/Cell.gd")

var move_from := Vector2()
var zoom_step = 0.1
var zoom_enabled := true
var movement_enabled := true
var perspective = 0

signal zoom_changed(value)

func _ready() -> void:

	EditorApi.camera_control = self
	EditorApi.area_display.connect("view_changed", self, "change_view")

func _process(delta: float) -> void:

	# Moving the camera
	if focused() and Input.is_action_pressed("camera_move") and movement_enabled:

		# Change camera position accordingly
		position = move_from - get_local_mouse_position()

func _unhandled_input(event: InputEvent) -> void:

	# Ignore if not focused
	if not focused(): return

	# Starting to move the camera
	if movement_enabled and event.is_action_pressed("camera_move"):

		# Set anchor point
		move_from = position + get_local_mouse_position()

	# Try to update the camera
	if zoom_enabled and event.is_action_pressed("camera_zoom_in") and $Camera.zoom.x > (zoom_step * 2):

		var prev = $Camera.zoom

		# Zoom in
		$Camera.zoom /= 1 + zoom_step

		# Move towards the mouse
		position += get_local_mouse_position() * ((prev - $Camera.zoom)/$Camera.zoom)

		emit_signal("zoom_changed", 1/$Camera.zoom.x)

	elif zoom_enabled and event.is_action_pressed("camera_zoom_out"):

		var prev = $Camera.zoom

		# Zoom out
		$Camera.zoom *= 1 + zoom_step

		# Move towards the mouse
		position -= get_local_mouse_position() * (($Camera.zoom - prev)/$Camera.zoom)

		emit_signal("zoom_changed", 1/$Camera.zoom.x)

func change_view(from: int):

	position = Cell.transform_position(position, posmod(from - perspective, 4))
	perspective = from

func focused() -> bool:

	var target: Node = $"/root/Editor/UI/Wrapper"

	# Find focus
	target = (target as Control).get_focus_owner()

	# Check
	while target:

		# If the target is a popup
		if target is Popup:

			# Return as not focused
			return false

		# Get parent
		target = target.get_parent()

	return true

func recentre():

	position = $"/root/Editor/AreaDisplay".map.center_position()

func set_zoom(value: float):

	$Camera.zoom = Vector2(1/value, 1/value)
