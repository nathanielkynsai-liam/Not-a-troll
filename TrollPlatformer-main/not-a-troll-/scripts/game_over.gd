extends Control

## Remembers the last level the player died in so Retry reloads that level!
static var last_level_path: String = "res://scenes/Level1.tscn"


func _ready() -> void:
	$CenterContainer/VBoxContainer/RetryButton.grab_focus()


func _on_retry_button_pressed() -> void:
	if last_level_path != "" and ResourceLoader.exists(last_level_path):
		get_tree().change_scene_to_file(last_level_path)
	else:
		get_tree().change_scene_to_file("res://scenes/Level1.tscn")


func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
