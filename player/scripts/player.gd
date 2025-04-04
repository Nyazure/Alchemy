extends CharacterBody3D


const SPEED = 0.6
const ACCEL = 0.05
const FRIC = 0.1
#const JUMP_VELOCITY = 4.5
@onready var _anim = self.get_node("AnimationPlayer")
@onready var _aim = self.get_node("Aim")
@onready var _debug_ray = self.get_node("RayCast3D")
var counter = 0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY
	var mousepos = get_viewport().get_mouse_position()
	var face_vec = Vector2(mousepos.x - get_viewport().size.x/2, mousepos.y - get_viewport().size.y/2 + 6).normalized()
	#_debug_aim.position = Vector3(float(face_vec.x), _debug_aim.position.y, float(face_vec.y)) * 0.06
	var _camera = get_viewport().get_camera_3d()
	var _debugaim =  (_camera.project_position(mousepos, 4/cos(deg_to_rad(30))) + Vector3(0, 0, -0.075) - self.position)
	_debug_ray.target_position = _debugaim #- _camera.position
	if _debug_ray.is_colliding():
		print(counter)
		counter += 1
	_debugaim.y = 0
	
	_aim.target_position = (_debugaim.normalized()) * 0.08
	var face_dir = face_vec.angle()
	
	if Input.is_action_pressed("left_click"):
		if _aim.is_colliding():
			if _aim.get_collider().has_method("destroy_block"):
				_aim.get_collider().destroy_block(_aim.get_collision_point() - _aim.get_collision_normal() * 0.01)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		#print(face_dir)
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCEL)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCEL)
		if velocity.length():
			_anim.speed_scale = clamp(velocity.length() * 2, 0.3, 1)
			if face_dir < -0.7 && face_dir > -2.3:
				_anim.play("run_b")
			elif face_dir < 2 && face_dir > 1:
				_anim.play("run_f")
			elif face_dir <= -2.3 || face_dir >= 2:
				_anim.play("run_l")
			elif face_dir <= 1 || face_dir >= -0.7:
				_anim.play("run_r")

	else:
		velocity.x = move_toward(velocity.x, 0, FRIC)
		velocity.z = move_toward(velocity.z, 0, FRIC)
		if face_dir < -0.7 && face_dir > -2.3:
			_anim.play("idle_b")
		elif face_dir < 2 && face_dir > 1:
			_anim.play("idle_f")
		elif face_dir <= -2.3 || face_dir >= 2:
			_anim.play("idle_l")
		elif face_dir <= 1 || face_dir >= -0.7:
			_anim.play("idle_r")
			
	move_and_slide()
