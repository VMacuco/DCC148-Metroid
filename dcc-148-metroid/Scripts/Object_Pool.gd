class_name ObjectPool
extends Node

@export var object_scene: PackedScene
@export var pool_size: int

var objects: Array[Node2D]
var available: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	objects.resize(pool_size)
	for i in range(pool_size):
		objects[i] = object_scene.instantiate()
		objects[i].process_mode = Node.PROCESS_MODE_DISABLED
		objects[i].hide()
		add_child(objects[i])
	available = pool_size

func get_from_pool() -> Node2D:
	var obj = objects[0]
	
	available -= 1
	objects[0] = objects[available]
	objects[available] = null
	
	if obj:
		obj.show()
		obj.process_mode = Node.PROCESS_MODE_ALWAYS
		
	return obj

func return_to_pool(obj: Node2D) -> void:
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	obj.hide()
	objects[available] = obj
	available += 1
