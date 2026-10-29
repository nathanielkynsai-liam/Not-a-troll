extends SceneTree

func _init() -> void:
	print("--- EXTRACTING BUTTONS ---")
	var tex = load("res://assets/menu_buttons.jpg") as Texture2D
	if not tex:
		print("ERROR: Could not load texture")
		quit()
		return

	var img = tex.get_image()
	if not img:
		print("ERROR: Could not get image")
		quit()
		return

	var rects = {
		"play_normal": Rect2i(45, 70, 275, 140),
		"play_hover": Rect2i(355, 45, 300, 185),
		"play_pressed": Rect2i(700, 70, 275, 140),
		"exit_normal": Rect2i(45, 365, 275, 140),
		"exit_hover": Rect2i(355, 340, 300, 185),
		"exit_pressed": Rect2i(700, 365, 275, 140)
	}

	for key in rects:
		var r = rects[key]
		var cropped = Image.create(r.size.x, r.size.y, false, Image.FORMAT_RGBA8)
		for y in range(r.size.y):
			for x in range(r.size.x):
				var px = img.get_pixel(r.position.x + x, r.position.y + y)
				var max_c = max(px.r, max(px.g, px.b))
				var min_c = min(px.r, min(px.g, px.b))
				var sat = max_c - min_c

				# The checkerboard is neutral grey (sat < 0.08) and medium brightness (0.32 < brightness < 0.68)
				var is_checker = (sat < 0.08 and px.r > 0.30 and px.r < 0.70)
				if is_checker:
					cropped.set_pixel(x, y, Color(0, 0, 0, 0))
				else:
					cropped.set_pixel(x, y, px)

		var out_path = "res://assets/" + key + ".png"
		var abs_path = ProjectSettings.globalize_path(out_path)
		var err = cropped.save_png(abs_path)
		print("Saved ", key, " to ", abs_path, " (err=", err, ")")

	quit()
