extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_name_value_text_submitted(new_text):
	if new_text.length() >= 2 && new_text.length() <= 12:
		$Submit.emit_signal("pressed")


func _on_name_value_text_changed(new_text):
	if new_text.length() >= 2 && new_text.length() <= 12:
		$Submit.disabled = false
	else:
		$Submit.disabled = true
