
extends Control


func _ready() -> void:
	$CenterContainer/VBoxContainer/PlayButton.grab_focus()


func _on_play_button_pressed() -> void:
	print("Play button pressed")
	get_tree().change_scene_to_file(
        "res://scenes/Level1.tscn"
	)

func _on_quit_button_pressed() -> void:
	print("Quit button pressed")
	get_tree().quit()
