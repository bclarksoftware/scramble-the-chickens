extends CanvasLayer

var masterVal = 1
var bgmVal = 1
var sfxVal = 1

var masterBusIndex = AudioServer.get_bus_index("Master")
var bgmBusIndex = AudioServer.get_bus_index("BGM")
var sfxBusIndex = AudioServer.get_bus_index("SFX")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _balanceAudio():
	AudioServer.set_bus_volume_db(masterBusIndex, linear_to_db(masterVal))
	AudioServer.set_bus_volume_db(bgmBusIndex, linear_to_db(bgmVal))
	AudioServer.set_bus_volume_db(sfxBusIndex, linear_to_db(sfxVal))


func _on_master_volume_slider_value_changed(value):
	masterVal = value
	_balanceAudio()


func _on_bgm_volume_slider_value_changed(value):
	bgmVal = value
	_balanceAudio()


func _on_sfx_volume_slider_value_changed(value):
	sfxVal = value
	_balanceAudio()


func _on_reset_button_pressed():
	if (masterVal == 1) && (bgmVal == 1) && (sfxVal == 1):
		return
	
	masterVal = 1
	bgmVal = 1
	sfxVal = 1
	$CenterContainer/GridContainer/MasterVolumeSlider.value = 1
	$CenterContainer/GridContainer/BGMVolumeSlider.value = 1
	$CenterContainer/GridContainer/SFXVolumeSlider.value = 1
	
	_balanceAudio()


func _on_confirm_button_pressed():
	self.hide()
