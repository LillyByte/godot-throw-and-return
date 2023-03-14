extends KinematicBody

#==================================================
# Integrate this script into your main character in Godot
# Set your camera_path to the camera of your character
# Set the axe_path to your weapon (or whatever child weapon of your character of you want to throw/return).
#==================================================

export (NodePath) var camera_path 
export (NodePath) var axe_path

var axe_speed = 25.0
var returning_speed = 25.0
var arc_height = 2.0
var is_throwing = false
var is_returning = false
var throw_target = Vector3.ZERO
var original_axe_position
var camera
var throw_progress = 0.0

func _ready():
    camera = get_node(camera_path)
    original_axe_position = get_node(axe_path).global_transform.origin

func _input(event):
    if event.is_action_pressed("ui_accept"):
        is_throwing = true
        throw_target = camera.project_ray_origin(camera.get_viewport().get_mouse_position()) + camera.project_ray_normal(camera.get_viewport().get_mouse_position()) * 20.0
        throw_progress = 0.0

func _physics_process(delta):
    var axe = get_node(axe_path)
    if is_throwing:
        throw_progress += delta * axe_speed
        var t = throw_progress / original_axe_position.distance_to(throw_target)
        var arc_point = original_axe_position.linear_interpolate(throw_target, t)
        arc_point.y += sin(t * PI) * arc_height
        axe.global_transform.origin = arc_point
        if axe.global_transform.origin.distance_to(throw_target) <= 0.5:
            is_throwing = false
            is_returning = true
            throw_progress = 0.0
    elif is_returning:
        throw_progress += delta * returning_speed
        var t = throw_progress / original_axe_position.distance_to(throw_target)
        var arc_point = axe.global_transform.origin.linear_interpolate(original_axe_position, t)
        arc_point.y += sin(t * PI) * arc_height
        axe.global_transform.origin = arc_point
        if axe.global_transform.origin.distance_to(original_axe_position) <= 0.5:
            is_returning = false
            axe.global_transform.origin = original_axe_position
