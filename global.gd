extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	SilentWolf.configure({
		"api_key": "IKa125N9Zz62SwPjO8JbW2zEF6an0EnhSLA2gtR6",
		"game_id": "ScrambletheChickens",
		"log_level": 0
	})

	SilentWolf.configure_scores({
		"open_scene_on_close": "res://src/HUD.tscn"
	})


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
