extends CanvasLayer

signal start_game

var hudScore = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("menu"):
		if get_tree().paused || $Leaderboard.visible || $Options.visible || $ButtonCenterContainer.visible:
			if $Leaderboard.visible:
				$Leaderboard.visible = false
				_on_leaderboard_visibility_changed()
			elif $Options.visible:
				$Options.visible = false
				_on_options_visibility_changed()
			elif get_tree().paused:
				hide_pause_menu()
		else:
			show_pause_menu()

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over(newHighScore : bool):
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout
	
	$ButtonCenterContainer/ButtonGridContainer/StartButton.text = "Restart"
	showAllButtons()
	
	if newHighScore:
		$Message.text = "New High Score!!!"
		$SubmitHighScoreCenterContainer/SubmitHighScoreGridContainer/ScoreValue.text = str(hudScore)
		$Message.show()
		
		# Display High Score Submit Menu
		var sw_result = await SilentWolf.Scores.get_score_position(hudScore).sw_get_position_complete
		var position = sw_result.position
		$SubmitHighScoreCenterContainer/SubmitHighScoreGridContainer/PlaceValue.text =  str(position)
		$SubmitHighScoreCenterContainer.show()
	else:
		$Message.text = "Meow.... Meow!!!!"
		$Message.show()
		await get_tree().create_timer(1.0).timeout

func show_pause_menu():
	$Message.text = "Paused"
	$ButtonCenterContainer/ButtonGridContainer/StartButton.text = "Resume"
	$Message.show()
	showAllButtons()
	
	get_tree().paused = true
	$Rain.material.set("shader_parameter/timeScale", 0.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func hide_pause_menu():
	$Message.hide()
	hideAllButtons()
	
	get_tree().paused = false
	$Rain.material.set("shader_parameter/timeScale", 1.0)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	
func update_score(score):
	$ScoreLabel.text = str('%03d' % score)
	hudScore = score

func _on_message_timer_timeout():
	$Message.hide()

# If we click the start/resume/restart button
func _on_start_button_pressed():
	hideAllButtons()

	if get_tree().paused:
		hide_pause_menu()
	else:
		start_game.emit()

func _on_quit_button_pressed():
	get_tree().quit()
	
func updateHealth(healthVal):
	if healthVal < 0:
		healthVal = 0
	$HealthLabel.text = str('%03d' % healthVal)

func hideAllButtons():
	$ButtonCenterContainer.hide()
	$SubmitHighScoreCenterContainer.hide()

func showAllButtons():
	$ButtonCenterContainer.show()
	
	if $Message.text == "New High Score!!!":
		$SubmitHighScoreCenterContainer.show()


func _on_leaderboard_pressed():
	$Leaderboard.show()
	$Leaderboard.reloadBoard()
	$Message.hide()
	hideAllButtons()


func _on_options_pressed():
	$Options.show()
	$Message.hide()
	hideAllButtons()


func _on_leaderboard_visibility_changed():
	if !$Leaderboard.visible:
		$Message.show()
		showAllButtons()


func _on_submit_high_score_pressed():
	$SubmitHighScoreCenterContainer.hide()
	SilentWolf.Scores.save_score($SubmitHighScoreCenterContainer/SubmitHighScoreGridContainer/NameValue.text, hudScore)
	

func _on_options_visibility_changed():
	if !$Options.visible:
		$Message.show()
		showAllButtons()
