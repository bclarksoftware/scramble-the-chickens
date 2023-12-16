extends CharacterBody3D

signal death

const FLOOR_NORMAL = Vector3(0.0, 1.0, 0.0)

@export var speed := 7.0
@export var gravity := 30.0
@export var jump_force := 12.0

var vel := Vector3(0.0, 0.0, 0.0)
var isAttacking = false
var isJumping = false
var state_machine
var isDead = false
var health = 100
var animationSpeedScale = 1.0

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")
	hide()
	
func start(pos):
	position = pos
	isDead = false
	health = 100
	show()

func _physics_process(delta: float) -> void:
	var current = state_machine.get_current_node()
	
	if isDead || !visible:
		$AnimationTree.advance(delta * animationSpeedScale)
		return
	elif position.y < -15:
		state_machine.travel("Death")
		_on_Death()
		return
	
	var direction_ground := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")).normalized()
	
	if not is_on_floor():
		vel.y -= gravity * delta
	
	vel = Vector3(
		direction_ground.x * speed,
		vel.y,
		direction_ground.y * speed)
	set_velocity(vel)
	set_up_direction(FLOOR_NORMAL)
	move_and_slide()

	if is_on_floor() or is_on_ceiling():
		if isJumping:
			$JumpAudio.play()
			isJumping = false
		vel.y = 0.0
		if state_machine.get_current_node() != "Attack_01":
			if vel.length() != 0 && current != "Run":
				state_machine.travel("Run")
			elif vel.length() == 0 && current != "Idle":
				state_machine.travel("Idle")

	if vel.x != 0:
		if vel.x < 0:
			$AnimatedSprite3D.scale.x = -5.0
		else:
			$AnimatedSprite3D.scale.x = 5.0
			
	$AnimationTree.advance(delta * animationSpeedScale)

func _unhandled_input(event: InputEvent) -> void:
	var current = state_machine.get_current_node()
	
	if isDead || !visible:
		return

	if event.is_action_pressed("jump") && is_on_floor():
		vel.y = jump_force
		state_machine.travel("Jump")
		$JumpAudio.play()
		isJumping = true
	if current != "Attack_01" && event.is_action_pressed("attack1"):
		state_machine.start("Attack_01")
		$Sword.play()

func _on_melee_area_area_entered(area):
	if area.is_in_group("chickenHurtBox"):
		area.take_damage()
		$Hit.play()
		
func _on_Death():
	isDead = true
	$DeathAudio.play()
	#hide()
	death.emit()

func _on_incoming_damage():
	if isDead || state_machine.get_current_node() == "Take_Damage":
		return
	
	health -= 15
	if health <= 0:
		state_machine.travel("Death")
		_on_Death()
	else:
		state_machine.travel("Take_Damage")
		$DeathAudio.play()

func getHealth():
	return health

func _on_animation_tree_animation_started(anim_name):
	if anim_name == "Attack_01":
		animationSpeedScale = 2.5


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "Attack_01":
		animationSpeedScale = 1
