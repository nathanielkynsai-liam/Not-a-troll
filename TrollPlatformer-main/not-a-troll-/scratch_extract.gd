extends SceneTree

func _init() -> void:
	var img = Image.load_from_file("res://assets/menu_buttons.jpg")
	var file = FileAccess.open("res://assets/buttons_info.txt", FileAccess.WRITE)
	file.store_line("Image size: " + str(img.get_size()))

	# Find bounds of all 6 buttons
	# Row 1: y around 60 to 220
	# Row 2: y around 350 to 520
	# Col 1: x around 30 to 330
	# Col 2: x around 350 to 670
	# Col 3: x around 690 to 990
	
	var col_ranges = [
		[30, 330],
		[350, 670],
		[690, 990]
	]
	var row_ranges = [
		[50, 240],
		[340, 530]
	]

	var names = [
		["play_normal", "play_hover", "play_pressed"],
		["exit_normal", "exit_hover", "exit_pressed"]
	]

	for r in range(2):
		for c in range(3):
			var min_x = 9999
			var max_x = 0
			var min_y = 9999
			var max_y = 0
			for y in range(row_ranges[r][0], row_ranges[r][1]):
				for x in range(col_ranges[c][0], col_ranges[c][1]):
					var col = img.get_pixel(x, y)
					# Check if not grey checkerboard
					# Checkerboard has r ~= g ~= b (diff < 0.08) and r > 0.4 and r < 0.6
					var is_checker = (abs(col.r - col.g) < 0.06 and abs(col.g - col.b) < 0.06 and col.r > 0.35 and col.r < 0.65)
					if not is_checker:
						if x < min_x: min_x = x
						if x > max_x: max_x = x
						if y < min_y: min_y = y
						if y > max_y: max_y = y

			var w = max_x - min_x + 1
			var h = max_y - min_y + 1
			file.store_line(names[r][c] + ": Rect2i(" + str(min_x) + ", " + str(min_y) + ", " + str(w) + ", " + str(h) + ")")
			
			# Also let's crop and save individual clean PNGs for each button!
			var button_img = Image.create(w, h, false, Image.FORMAT_RGBA8)
			for by in range(h):
				for bx in range(w):
					var col = img.get_pixel(min_x + bx, min_y + by)
					var is_checker = (abs(col.r - col.g) < 0.06 and abs(col.g - col.b) < 0.06 and col.r > 0.35 and col.r < 0.65)
					if is_checker:
						button_img.set_pixel(bx, by, Color(0, 0, 0, 0)) # Transparent!
					else:
						button_img.set_pixel(bx, by, col)
			button_img.save_png("res://assets/" + names[r][c] + ".png")

	file.close()
	quit()

