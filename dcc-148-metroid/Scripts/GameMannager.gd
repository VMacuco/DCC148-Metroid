extends Node

signal hp_changed(new_hp: int)


var MAX_HP: int = 99
var inicial_hp: int = 15
var armadillo_upgarade: bool = false
var last_door: bool = false


var _player_hp = inicial_hp

var player_hp: int:
	get:
		return _player_hp
	set(value):
		_player_hp = clampi(value, 0, MAX_HP)
		hp_changed.emit(_player_hp)


func start_new_game() -> void:
	player_hp = inicial_hp
	armadillo_upgarade = false
	last_door = false
	
func game_restart() -> void:
	player_hp = inicial_hp
	last_door = false
