extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	SilentWolf.configure({
		"api_key": "",
		"game_id": "",
		"log_level": 0
	})

	SilentWolf.configure_scores({
		"open_scene_on_close": "res://src/HUD.tscn"
	})


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
