extends Node

signal hp_changed(new_hp: int)
signal player_died

var MAX_HP: int = 99
var inicial_hp: int = 35
var armadillo_upgarade: bool = false
var last_door: bool = false
var immortal_mode: bool = false


var _player_hp = inicial_hp

var player_hp: int:
	get:
		return _player_hp
	set(value):
		var min_hp = 1 if immortal_mode else 0
		var clamped = clampi(value, min_hp, MAX_HP)
		
		var was_alive = _player_hp > 0
		_player_hp = clamped
		hp_changed.emit(_player_hp)
		
		if was_alive and _player_hp <= 0:
			player_died.emit()
		


func start_new_game() -> void:
	player_hp = inicial_hp
	armadillo_upgarade = false
	last_door = false
	
func game_restart() -> void:
	player_hp = inicial_hp
	last_door = false
