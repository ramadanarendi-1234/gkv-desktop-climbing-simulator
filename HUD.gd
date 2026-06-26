extends CanvasLayer

onready var timer_label = $Control/TimerLabel
onready var objective_label = $Control/ObjectiveLabel
onready var height_label = $Control/HeightLabel
onready var pb_label = $Control/PBLabel
onready var results_panel = $Control/ResultsPanel
onready var crosshair = $Control/Crosshair

var timer_running = false
var current_time = 0.0

func _ready():
	results_panel.hide()
	objective_label.text = "Grab a hold to start!"
	timer_label.text = "Time: 00:00.00"
	
	if RunHistory:
		var pb = RunHistory.get_personal_best()
		if pb < 0:
			pb_label.text = "PB: --:--.--"
		else:
			pb_label.text = "PB: " + format_time(pb)

func _process(delta):
	if timer_running:
		current_time += delta
		timer_label.text = "Time: " + format_time(current_time)

func format_time(time_sec: float) -> String:
	var mins = int(time_sec) / 60
	var secs = int(time_sec) % 60
	var msecs = int((time_sec - int(time_sec)) * 100)
	return "%02d:%02d.%02d" % [mins, secs, msecs]

func start_timer():
	if not timer_running:
		timer_running = true
		objective_label.text = "Reach the Summit!"

func stop_timer():
	timer_running = false

func reset_timer():
	timer_running = false
	current_time = 0.0
	timer_label.text = "Time: 00:00.00"
	objective_label.text = "Grab a hold to start!"
	results_panel.hide()

func update_height(y: float):
	height_label.text = "Height: %.1fm" % max(0.0, y)

func show_results(is_new_pb: bool):
	timer_running = false
	results_panel.show()
	results_panel.get_node("TimeValue").text = format_time(current_time)
	
	var pb = RunHistory.get_personal_best()
	if is_new_pb:
		results_panel.get_node("PBValue").text = "⭐ New PB!"
	else:
		results_panel.get_node("PBValue").text = "PB: " + format_time(pb)
		
	results_panel.get_node("AttemptValue").text = "Attempt #" + str(RunHistory.get_run_count())
