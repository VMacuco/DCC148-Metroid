extends Node

const Sequence: Array[StringName] = [
	&"look_up", &"look_up",
	&"ball",    &"ball",
	&"move_left", &"move_right",
	&"move_left", &"move_right",
	&"jump",    &"shoot",
]

var _history:Array[StringName] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	for action in Sequence:
		if event.is_action_pressed(action):
			_register(action)
			return

func _register(action: StringName) -> void:
	if _history.size() < Sequence.size() and action == Sequence[_history.size()]:
		_history.append(action)
		if _history.size() == Sequence.size():
			_history.clear()
			_toggle_imortal()
	elif action == Sequence[0]:
		_history = [action]
	else:
		_history.clear()

func _toggle_imortal()->void:
	GameMannager.immortal_mode = not GameMannager.immortal_mode


	
	
 
