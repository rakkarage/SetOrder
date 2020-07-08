extends ItemList

onready var _up = $VBoxContainer/Up
onready var _down = $VBoxContainer/Down
onready var _save = $VBoxContainer/Save

var _data := {}
var _started := false
var _marker := "[resource]"
var _drag := -1

func _ready():
	_up.connect("pressed", self, "_onUp")
	_down.connect("pressed", self, "_onDown")
	_save.connect("pressed", self, "_onSave")
	_read()
	for key in _data:
		if key != "" and key != "header":
			add_item(key + " " + _data[key]["name"])

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				_drag = get_item_at_position(event.global_position, true)
			else:
				move_item(_drag, get_item_at_position(event.global_position, true))

func _onUp():
	if not is_anything_selected():
		return
	var index = get_selected_items()[0]
	if index > 0:
		move_item(index, index - 1)
		ensure_current_is_visible()

func _onDown():
	if not is_anything_selected():
		return
	var index = get_selected_items()[0]
	if index < get_item_count():
		move_item(index, index + 1)
		ensure_current_is_visible()

func _onSave():
	_write()

func _write() -> void:
	var file = File.new()
	if file.open("res://out.txt", File.WRITE) == OK:
		for key in _data:
			if key == "header":
				for line in _data[key].data:
					file.store_line(line)
		for i in get_item_count():
			var oldKey := get_item_text(i).split(" ")[0]
			for line in _data[oldKey].data:
				var test = str(i) + "/" + line.split("/", true, 1)[1]
				file.store_line(test)
		file.close()

#{ "1": "name" }
#{ "1": { "name": "name", "data": ["one", "two"] } }

func _read() -> void:
	var file = File.new()
	if file.open("res://in.txt", File.READ) == OK:
		_data["header"] = { "data": [] }
		while not file.eof_reached():
			var line = file.get_line()
			if not _started:
				_data["header"].data.append(line)
				if line == _marker:
					_started = true
				continue
			var s = line.split("/")
			var x = line.split("\"")
			var key = s[0]
			if not _data.has(str(key)):
				_data[str(key)] = {}
				_data[str(key)]["data"] = []
			_data[str(key)]["data"].append(line)
			if x.size() > 1:
				_data[str(key)]["name"] = x[1]
		file.close()
