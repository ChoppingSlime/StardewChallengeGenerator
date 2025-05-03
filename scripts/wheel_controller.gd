# wheel_controller.gd
extends Control

signal wheel_stopped(selected_item)

@export var wheel_items: Array = []
@export var spin_time_min: float = 3.0
@export var spin_time_max: float = 5.0
@export var initial_speed: float = 30.0
@export var deceleration: float = 15.0

@onready var wheel_container = $WheelContainer
@onready var selector = $Selector
@onready var animation_player = $AnimationPlayer

var is_spinning: bool = false
var current_angle: float = 0.0
var current_speed: float = 0.0
var spin_time: float = 0.0
var elapsed_time: float = 0.0
var selected_index: int = -1
var fixed_selection: int = -1  # Set to force a specific selection, -1 for random

func _ready() -> void:
	setup_wheel()

func setup_wheel() -> void:
	# Clear any existing wheel segments
	for child in wheel_container.get_children():
		child.queue_free()
	
	# Skip if no items
	if wheel_items.size() == 0:
		return
		
	# Calculate segment angle
	var segment_angle = 360.0 / wheel_items.size()
	
	# Create segments
	for i in range(wheel_items.size()):
		var segment = create_segment(i, segment_angle)
		wheel_container.add_child(segment)

func create_segment(index: int, segment_angle: float) -> Control:
	var segment = Control.new()
	segment.name = "Segment" + str(index)
	
	# Position segment (segments are created from the top, clockwise)
	var angle = deg_to_rad(index * segment_angle)
	var radius = min(size.x, size.y) * 0.4
	
	# Create segment visuals
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	
	# Create triangle points
	points.append(Vector2(0, 0))  # Center
	points.append(Vector2(radius * sin(angle), -radius * cos(angle)))  # Start edge
	points.append(Vector2(radius * sin(angle + deg_to_rad(segment_angle)), -radius * cos(angle + deg_to_rad(segment_angle))))  # End edge
	
	# Set polygon properties
	polygon.polygon = points
	polygon.color = Color(randf(), randf(), randf(), 1.0)  # Random color
	segment.add_child(polygon)
	
	# Add item label
	var label = Label.new()
	label.text = wheel_items[index].name if wheel_items[index] is Resource else str(wheel_items[index])
	label.position = Vector2(radius * 0.6 * sin(angle + deg_to_rad(segment_angle/2)), 
							-radius * 0.6 * cos(angle + deg_to_rad(segment_angle/2)))
	label.pivot_offset = label.size / 2
	label.rotation = angle + deg_to_rad(segment_angle/2) + PI/2
	segment.add_child(label)
	
	return segment

func spin() -> void:
	if is_spinning:
		return
	
	is_spinning = true
	current_speed = initial_speed
	spin_time = randf_range(spin_time_min, spin_time_max)
	elapsed_time = 0.0
	
	# Predetermine final position if fixed_selection is set
	if fixed_selection >= 0 and fixed_selection < wheel_items.size():
		selected_index = fixed_selection
	else:
		selected_index = randi() % wheel_items.size()

func _process(delta: float) -> void:
	if is_spinning:
		elapsed_time += delta
		
		# Update speed with deceleration
		var t = min(elapsed_time / spin_time, 1.0)
		current_speed = initial_speed * (1.0 - t)
		
		# Update rotation
		current_angle += current_speed * delta
		wheel_container.rotation = current_angle
		
		# Check if spin is complete
		if elapsed_time >= spin_time:
			finalize_spin()

func finalize_spin() -> void:
	is_spinning = false
	
	# Calculate segment angle
	var segment_angle = 360.0 / wheel_items.size()
	
	# Calculate final angle to ensure selected segment aligns with selector
	var target_angle = selected_index * segment_angle
	target_angle = fmod(target_angle + 360.0, 360.0)
	
	# Create animation to smoothly move to final position
	animation_player.remove_animation("finalize")
	var anim = Animation.new()
	var track_idx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, "WheelContainer:rotation")
	anim.track_insert_key(track_idx, 0.0, wheel_container.rotation)
	anim.track_insert_key(track_idx, 0.5, deg_to_rad(target_angle))
	animation_player.add_animation("finalize", anim)
	
	# Play animation
	animation_player.play("finalize")
	await animation_player.animation_finished
	
	# Emit signal with selected item
	emit_signal("wheel_stopped", wheel_items[selected_index])

func set_wheel_items(items: Array) -> void:
	wheel_items = items
	setup_wheel()

func force_selection(index: int) -> void:
	fixed_selection = index
