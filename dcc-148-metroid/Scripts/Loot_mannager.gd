extends Node

@export var drop_chance = 0.3
@export var health_orb: PackedScene = preload("res://Scenes/Player/heal_orb.tscn")
@export var enemy_group = "Enemy"

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	print("=== LootManager READY (autoload carregou) ===")
	print("=== enemy_group configurado = '", enemy_group, "' ===")
	rng.randomize()
	get_tree().node_added.connect(_on_node_added)
	_scan_existing_enemies.call_deferred()

func _scan_existing_enemies() -> void:
	var enemies := get_tree().get_nodes_in_group(enemy_group)
	print("[Loot] inimigos pré-existentes encontrados: ", enemies.size())
	for e in enemies:
		_register_enemy(e)

func _on_node_added(node: Node) ->void:
	if not node is Node2D:
		return
	_register_enemy.call_deferred(node)

func _register_enemy(node: Node2D) -> void:
	if not is_instance_valid(node):
		return
	if not node.is_in_group(enemy_group):
		return
	if node.get_meta("loot_connected", false):
		return
	node.set_meta("loot_connected", true)

	print("[Loot] ✓ registrando ", node.name,
		" | died? ", node.has_signal("died"))

	if node.has_signal("died"):
		node.died.connect(_on_enemy_died.bind(node), CONNECT_ONE_SHOT)
	node.tree_exiting.connect(_on_enemy_tree_exiting.bind(node), CONNECT_ONE_SHOT)
	print("[Loot] conexões feitas para ", node.name)


func _on_enemy_died(node: Node2D) -> void:
	print("[Loot] _on_enemy_killed chamado para ", node.name, " válido: ", is_instance_valid(node))
	if not is_instance_valid(node):
		return
	if node.get_meta("loot_handled", false):
		print("[Loot] _on_enemy_killed chamado para ", node.name, " válido: ", is_instance_valid(node))
		return
	node.set_meta("loot_handled", true)
	var scene := get_tree().current_scene
	if scene == null or scene.is_queued_for_deletion():
		print("[Loot] current_scene inválida")
		return
	_try_drop(node.global_position)

func _on_enemy_tree_exiting(node: Node2D) -> void:
	var scene = get_tree().current_scene
	if scene == null or scene.is_queued_for_deletion():
		return
	_try_drop(node.global_position)

func _try_drop(pos: Vector2) -> void:
	print("[Loot] _try_drop em ", pos)
	
	if health_orb == null:
		print("[Loot] health_orb == null")
		return
	if rng.randf() > drop_chance:
		print("[Loot] RNG falhou")
		return
	
	var scene = get_tree().current_scene
	if scene == null:
		print("[Loot] current_scene null")
		return
	
	var heal = health_orb.instantiate()
	if heal ==null:
		print("[Loot] heal não é Node2D!")
		return
	scene.add_child.call_deferred(heal)
	heal.global_position = pos
	print("[Loot] orb criado em ", heal.global_position,
		" | pai: ", scene.name,
		" | visível: ", heal.visible,
		" | z_index: ", heal.z_index)
	
