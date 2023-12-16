extends Node3D

@export var mob_scene: PackedScene
@export var noChickenMode: bool
var score
var gameover = false
var sessionHighScore = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#Let the chickens know where you at
	for chicken in get_tree().get_nodes_in_group("mobs"):
		chicken.setPlayer($Cat)
		
	$HUD.updateHealth($Cat.getHealth())

func _on_mob_timer_timeout():
	if (noChickenMode):
		return

	var mob = mob_scene.instantiate()
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	mob.position = mob_spawn_location.position
	add_child(mob)
	mob.death.connect(_on_chicken_mob_death)

func _on_hud_start_game():
	get_tree().call_group("mobs", "queue_free")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	$BackgroundMusic.play()
	
	score = 0
	gameover = false
	
	$Cat.start($StartPosition.position)
	$StartTimer.start()
	_on_mob_timer_timeout()
	_on_mob_timer_timeout()
	
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")


func _on_start_timer_timeout():
	$MobTimer.start()

func _on_chicken_mob_death():
	score += 1
	$HUD.update_score(score)

func _on_player_death():
	$MobTimer.stop()
	$BackgroundMusic.stop()
	$EndMusic.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if (score > sessionHighScore):
		$HUD.show_game_over(true)
		sessionHighScore = score
	else:
		$HUD.show_game_over(false)

func _on_background_music_finished():
	if gameover == false:
		$BackgroundMusic.stream_paused = false
		$BackgroundMusic.play()
