extends Control

@onready var entries_container = $Panel/VBoxContainer/ScrollContainer/LeaderboardList
@onready var http_request = $Panel/HTTPRequest
# We'll add this node
var loading_label: Label
func _ready():
	# Verify nodes exist
	$Panel/VBoxContainer/ScrollContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	$Panel/VBoxContainer/ScrollContainer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	if not entries_container:
		push_error("Entries container not found! Check node path.")
	if not http_request:
		http_request = HTTPRequest.new()
		add_child(http_request)
	
	# Create loading label if it doesn't exist
	if not loading_label:
		loading_label = Label.new()
		loading_label.name = "LoadingLabel"
		loading_label.text = "Loading..."
		loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		loading_label.add_theme_font_size_override("font_size", 24)
		$Panel.add_child(loading_label)
		loading_label.size = Vector2(200, 50)
		loading_label.position = $Panel.size / 2 - loading_label.size / 2
	
	$Panel/VBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)
	http_request.request_completed.connect(_on_request_completed)
	
	# Show loading before fetching
	loading_label.show()
	fetch_leaderboard()

func fetch_leaderboard():
	var error = http_request.request("https://cloudcomputinggame.onrender.com/leaderboard")
	if error != OK:
		push_error("Failed to start request: " + str(error))
		loading_label.text = "Failed to connect"

func _on_request_completed(_result, response_code, _headers, body):
	# Hide loading label regardless of result
	loading_label.hide()
	
	print("Raw response: ", body.get_string_from_utf8())
	
	if response_code == 200:
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		if typeof(parsed) == TYPE_ARRAY:
			show_leaderboard(parsed)
		else:
			push_error("Invalid data format")
			loading_label.text = "Invalid data format"
			loading_label.show()
	else:
		push_error("Request failed: " + str(response_code))
		loading_label.text = "Failed to load (Error: " + str(response_code) + ")"
		loading_label.show()

func _compare_scores_desc(a, b) -> bool:
	return a["score"] > b["score"]

func show_leaderboard(data):
	# Clear existing
	for child in entries_container.get_children():
		child.queue_free()

	data.sort_custom(Callable(self, "_compare_scores_desc"))

	for i in range(data.size()):
		var entry = data[i]

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 90)

		var row_padding = MarginContainer.new()
		row_padding.add_theme_constant_override("margin_top", 4)
		row_padding.add_theme_constant_override("margin_bottom", 4)
		row_padding.add_child(hbox)

		var rank = Label.new()
		rank.text = "#%d" % (i + 1)
		rank.custom_minimum_size.x = 40
		

		var name = Label.new()
		name.text = entry["name"]
		name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		

		var score = Label.new()
		score.text = str(entry["score"])
		

		hbox.add_child(rank)
		hbox.add_child(name)
		hbox.add_child(score)

		entries_container.add_child(row_padding)
		if i < data.size() - 1:
			entries_container.add_child(HSeparator.new())

func _on_back_button_pressed():
	queue_free()
