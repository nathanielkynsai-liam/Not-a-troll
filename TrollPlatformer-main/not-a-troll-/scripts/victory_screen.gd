extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/PlayAgainButton.grab_focus()


func _on_play_again_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

