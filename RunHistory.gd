extends Node

var save_path = "user://run_history.json"
var runs = []

func _ready():
	load_runs()

func load_runs():
	var file = File.new()
	if file.file_exists(save_path):
		file.open(save_path, File.READ)
		var text = file.get_as_text()
		file.close()
		
		var result = JSON.parse(text)
		if result.error == OK and typeof(result.result) == TYPE_ARRAY:
			runs = result.result
		else:
			runs = []
	else:
		runs = []

func save_runs():
	var file = File.new()
	file.open(save_path, File.WRITE)
	file.store_string(JSON.print(runs, "  "))
	file.close()

func save_run(time_sec: float, completed: bool):
	var date = OS.get_datetime()
	var date_str = "%04d-%02d-%02d %02d:%02d:%02d" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
	
	runs.append({
		"time": time_sec,
		"date": date_str,
		"completed": completed
	})
	save_runs()

func get_personal_best() -> float:
	var best = -1.0
	for r in runs:
		if r.completed:
			if best < 0 or r.time < best:
				best = r.time
	return best

func get_run_history() -> Array:
	return runs

func get_run_count() -> int:
	return runs.size()

func get_completed_count() -> int:
	var count = 0
	for r in runs:
		if r.completed:
			count += 1
	return count
