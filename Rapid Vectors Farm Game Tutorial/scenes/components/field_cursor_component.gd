class_name FieldCursorComponent
extends Node

# Reference to TilemapLayer representing grass
@export var grass_tilemap_layer: TileMapLayer
# Reference to TilemapLayer representing tilled soil
@export var tilled_soil_tilemap_layer: TileMapLayer
# Identifier for terrain set
@export var terrain_set: int = 0
# Identifier for tilled soil terrain
@export var terrain: int = 3

# Finds player node tagged in "player" group in the scene
@onready var player: Player = get_tree().get_first_node_in_group("player")

# Variables for mouse and tile positioning
var mouse_position: Vector2
var cell_position: Vector2i
var cell_source_id: int
var local_cell_position: Vector2
var distance: float


func _unhandled_input(event: InputEvent) -> void:
	# When crl + lmb is pressed and player is holding hoe, calls get_call_under_mouse and remove_tilled_soil_cell
	if event.is_action_pressed("remove_dirt"):
		if ToolManager.selected_tool == DataTypes.Tools.TillGround:
			get_call_under_mouse()
			remove_tilled_soil_cell()

	# When lmb is pressed and player is holding hoe, calls get_call_under_mouse and add_tilled_soil_cell
	if event.is_action_pressed("hit") and not event.is_action_pressed("remove_dirt"):
		if ToolManager.selected_tool == DataTypes.Tools.TillGround:
			get_call_under_mouse()
			add_tilled_soil_cell()


func get_call_under_mouse() -> void:
	# Retrives mouse position in the viewport
	mouse_position = get_viewport().get_mouse_position()
	# Finds which tile is uder mouse by converting from local coordinates to the tilemap grid position
	cell_position = grass_tilemap_layer.local_to_map(mouse_position.floor())
	# Gets tile id
	cell_source_id = grass_tilemap_layer.get_cell_source_id(cell_position)
	# Finds ingame position of tile to compare it with player position
	local_cell_position = grass_tilemap_layer.map_to_local(cell_position)
	# Calculates distance between player and selected tile
	distance = player.global_position.distance_to(local_cell_position)


func add_tilled_soil_cell() -> void:
	# Checks if the tile is within 20 units of the player and ensures the tile is valid
	if distance < 20.0 && cell_source_id != -1:
		# Tills selected tile
		tilled_soil_tilemap_layer.set_cells_terrain_connect([cell_position], terrain_set, terrain, true)
		
		# set_cells_terrain_connect([cells], terrain_set, terrain, ignore_empty_terrains)
		# cells - list of tile positions where terrain should be applied
		# terrain_set - terrain set index to use
		# terrain - specific terrain type to apply (-1 = reset to deafult state)
		# ignore_empty_terrains - if true prevents terrain updates on empty tiles to avoid disconnecting terrain pieces


func remove_tilled_soil_cell() -> void:
	# Checks if the tile is within 20 units of the player
	if distance < 20.0:
		# Changes selected tile deafult state
		tilled_soil_tilemap_layer.set_cells_terrain_connect([cell_position], 0, -1, true)
	
