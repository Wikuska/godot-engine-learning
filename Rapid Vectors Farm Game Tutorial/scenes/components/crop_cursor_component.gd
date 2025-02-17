class_name CropsCursorComponent
extends Node

# Reference to TilemapLayer where crops can be planted
@export var tilled_soil_tilemap_layer: TileMapLayer

# Finds player node tagged in "player" group in the scene
@onready var player: Player = get_tree().get_first_node_in_group("player")

# Preloads the Corn and Tomato plant scenes
var corn_plant_scene = preload("res://scenes/objects/plants/corn.tscn")
var tomato_plant_scene = preload("res://scenes/objects/plants/tomato.tscn")

# Variables for mouse and tile positioning
var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var local_call_position: Vector2
var distance: float

func _unhandled_input(event: InputEvent) -> void:
	# When crl + lmb is pressed and player is holding hoe, calls get_call_under_mouse and remove_crop
	if event.is_action_pressed("remove_dirt"):
		if ToolManager.selected_tool == DataTypes.Tools.TillGround:
			get_call_under_mouse()
			remove_crop()
	
	# When lmb is pressed and player is holding hoe, calls get_call_under_mouse and add_cropadd_crop
	if event.is_action_pressed("hit") and not event.is_action_pressed("remove_dirt"):
		if ToolManager.selected_tool == DataTypes.Tools.PlantCorn or ToolManager.selected_tool == DataTypes.Tools.PlantTomato:
			get_call_under_mouse()
			add_crop()


func get_call_under_mouse() -> void:
	# Retrives mouse position in the viewport
	mouse_position = get_viewport().get_mouse_position()
	# Finds which tile is uder mouse by converting from local coordinates to the tilemap grid position
	cell_position = tilled_soil_tilemap_layer.local_to_map(mouse_position.floor())
	# Gets tile id
	cell_source_id = tilled_soil_tilemap_layer.get_cell_source_id(cell_position)
	# Finds ingame position of tile to compare it with player position
	local_call_position = tilled_soil_tilemap_layer.map_to_local(cell_position)
	# Calculates distance between player and selected tile
	distance = player.global_position.distance_to(local_call_position)


func add_crop() -> void:
	# Checks if the tile is within 20 units of the player
	if distance < 20.0:
		# Checks if player is currently holding corn seeds
		if ToolManager.selected_tool == DataTypes.Tools.PlantCorn:
			# Creates an instance of corn plnt scene
			var corn_instance = corn_plant_scene.instantiate() as Node2D
			# Sets instance position to selected tile position
			corn_instance.global_position = local_call_position
			# Add crop as child to "CropsFields"
			get_parent().find_child("CropFields").add_child(corn_instance)
		
		# Checks if player is currently holding tomato seeds
		if ToolManager.selected_tool == DataTypes.Tools.PlantTomato:
			var tomato_instance = tomato_plant_scene.instantiate() as Node2D
			tomato_instance.global_position = local_call_position
			get_parent().find_child("CropFields").add_child(tomato_instance)


func remove_crop() -> void:
	# Checks if the tile is within 20 units of the player
	if distance < 20.0:
		# Finds all nodes inside "CropFields"
		var crop_nodes = get_parent().find_child("CropFields").get_children()
		
		# Loops through each crop node
		for node: Node2D in crop_nodes:
			# Checks if node position matches cell position
			if node.global_position == local_call_position:
				# When match is found, it removes crop from scene
				node.queue_free()
