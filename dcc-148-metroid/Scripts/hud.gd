extends CanvasLayer

@onready var Hp_display = $MarginContainer/VBoxContainer/HBoxContainer2/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameMannager.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(GameMannager.player_hp)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_hp_changed(hp: int)->void:
	Hp_display.text = "%02d" % hp 
