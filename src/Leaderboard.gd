@tool
extends CanvasLayer

const ScoreItem = preload("res://addons/silent_wolf/Scores/ScoreItem.tscn")
const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

var list_index = 0
var ld_name = "main"

func _ready():
	var scores = []
	if ld_name in SilentWolf.Scores.leaderboards:
		scores = SilentWolf.Scores.leaderboards[ld_name]
	
	if len(scores) > 0: 
		render_board(scores) # This is almost used as a caching value so we don't have to call the api again
	else:
		# use a signal to notify when the high scores have been returned, and show a "loading" animation until it's the case...
		add_loading_scores_message()
		var sw_result: Dictionary = await SilentWolf.Scores.get_scores().sw_get_scores_complete
		scores = sw_result["scores"]
		hide_message()
		render_board(scores)

func reloadBoard():
	var node = $Board/HighScores/ScrollContainer/ScoreItemContainer
	list_index = 0
	
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
	
	var scores = []
	# use a signal to notify when the high scores have been returned, and show a "loading" animation until it's the case...
	add_loading_scores_message()
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(0).sw_get_scores_complete
	scores = sw_result["scores"]
	hide_message()
	render_board(scores)

func render_board(scores: Array) -> void:
	if scores.is_empty():
		add_no_scores_message()
	else:
		for score in scores:
			add_item(score.player_name, str(int(score.score)))
			
			#var time = display_time(scores[i].score)
			#add_item(score.player_name, time)


#func display_time(time_in_millis):
#	var minutes = int(floor(time_in_millis / 60000))
#	var seconds = int(floor((time_in_millis % 60000) / 1000))
#	var millis = time_in_millis - minutes*60000 - seconds*1000
#	var displayable_time = str(minutes) + ":" + str(seconds) + ":" + str(millis)
#	return displayable_time

func add_item(player_name: String, score_value: String) -> void:
	var item = ScoreItem.instantiate() #ScoreItem.instance()
	list_index += 1
	item.get_node("PlayerName").text = str(list_index) + str(". ") + player_name
	item.get_node("Score").text = score_value
	item.offset_top = list_index * 100
	$Board/HighScores/ScrollContainer/ScoreItemContainer.add_child(item)

func add_no_scores_message():
	var item = $"Board/MessageContainer/TextMessage"
	item.text = "No scores yet!"
	$"Board/MessageContainer".show()
	item.offset_top = 135


func add_loading_scores_message() -> void:
	var item = $"Board/MessageContainer/TextMessage"
	item.text = "Loading scores..."
	$"Board/MessageContainer".show()
	item.offset_top = 135


func hide_message() -> void:
	$"Board/MessageContainer".hide()


func _on_close_button_pressed():
	self.hide()
