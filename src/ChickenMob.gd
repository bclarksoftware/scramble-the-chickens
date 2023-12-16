extends CharacterBody3D

signal death

const JUMP_VELOCITY = 4.5

var speed = 6.0
var health = 100
var state_machine
var canAttack = true
var player = null
var lastKnownPlayerDir = Vector3.ZERO
var dead = false
var gravity = 1
var animationSpeedScale = 1.0

func _ready():
	state_machine = $AnimationTree.get("parameters/playback")
	state_machine.travel("Idle")

func _physics_process(delta):
	var motion = Vector3.ZERO
	var currentAnim = state_machine.get_current_node()
	
	$AnimationTree.advance(delta * animationSpeedScale)
	
	if (dead || (player && player.isDead)):
		return
	elif position.y <= -50:
		queue_free()
		return

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		state_machine.travel("Fly")
	elif is_on_floor() or is_on_ceiling():
		velocity.y = 0.0
		if currentAnim != "Attack":
			if velocity.length() != 0 && currentAnim != "Walk":
				state_machine.travel("Walk")
			elif velocity.length() == 0 && currentAnim != "Idle":
				state_machine.travel("Idle")

	if player && currentAnim != "Damage":
		if currentAnim == "Attack":
			motion += lastKnownPlayerDir
			speed = 12
		else:
			lastKnownPlayerDir = self.position.direction_to(player.position)
			motion += lastKnownPlayerDir
			speed = 7.5
			
			if (canAttack && (position.distance_to(player.position) <= 5)):
				canAttack = false
				$AttackTimer.start()
				state_machine.travel("Attack")

	var direction = (transform.basis * motion).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Flip sprite based on direction.
	if velocity.x != 0 || currentAnim == "Attack":
		if velocity.x < 0:
			$AnimatedSprite3D.scale.x = -5.0
		else:
			$AnimatedSprite3D.scale.x = 5.0

	# Update movement
	move_and_slide()

func _on_chicken_incoming_damage():
	if dead:
		return
	
	health -= 50
	if health <= 0:
		state_machine.start("Death")
		$Despawn.start()
		$CollisionShape3D.set_deferred("disabled", true)
		$ChickenHurtArea/CollisionShape3D.set_deferred("disabled", true)
		$AnimatedSprite3D/MeleeArea/MeleeCollisionShape3D.set_deferred("disabled", true)
		$ChickenTalk.volume_db = 0
		$ChickenTalk.play()
		dead = true
		$Feathers.emitting = true
		death.emit()
	else:
		state_machine.travel("Damage")
		$ChickenTalk.volume_db = -5
		$ChickenTalk.play()

func _on_despawn_timeout():
	queue_free()
	
func setPlayer(playerParm):
	self.player = playerParm

func _on_attack_timer_timeout():
	canAttack = true

func _on_chicken_melee_area_entered(area):
	if area.is_in_group("playerHurtBox"):
		area.take_damage()
