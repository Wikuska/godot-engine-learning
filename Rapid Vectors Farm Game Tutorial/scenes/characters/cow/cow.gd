extends NonPlayableCharacter

func _ready() -> void:
	walk_cycles = randf_range(min_walk_cicle, max_walk_cicle)
