extends Node2D

# Preloads corn_harvest_state for later use
var tomato_harvest_scene = preload("res://scenes/objects/plants/tomato_harvest.tscn")

# Gets nodes references
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var watering_particles: GPUParticles2D = $WateringParticles
@onready var flowering_particles: GPUParticles2D = $FloweringParticles
@onready var growth_cycle_component: GrowthCycleComponent = $GrowthCycleComponent
@onready var hurt_component: HurtComponent = $HurtComponent

var growth_state: DataTypes.GrowthStates = DataTypes.GrowthStates.Seed
var start_tomato_frame_offset: int = 6

func _ready() -> void:
	# Disables particle effects
	watering_particles.emitting = false
	flowering_particles.emitting = false 
	
	# Connects signals with coresponding functions
	hurt_component.hurt.connect(on_hurt)
	growth_cycle_component.crop_maturity.connect(on_crop_maturity)
	growth_cycle_component.crop_harvesting.connect(on_crop_harvesting)

# Called every frame
func _process(_delta: float) -> void:
	# Updates current growth_state based on state returned from growth_cycle_component func
	growth_state = growth_cycle_component.get_current_growth_state()
	# Changes sprite frame to reflect crop current growth state
	sprite_2d.frame = growth_state + start_tomato_frame_offset
	
	# If crop reaches maturity it starts emitting flowering particles
	if growth_state == DataTypes.GrowthStates.Maturity:
		flowering_particles.emitting = true


func on_hurt(_hit_damage: int) -> void:
	# If crop isn't already watered
	if !growth_cycle_component.is_watered:
		# Starts emitting watering particles for 5 seconds
		watering_particles.emitting = true
		await get_tree().create_timer(5.0).timeout
		watering_particles.emitting = false
		# Sets is_watered var in growth_cycle_component to true
		growth_cycle_component.is_watered = true


func on_crop_maturity() -> void:
	# When crop reaches maturity it starts emitting flowering particles
	flowering_particles.emitting = true


func on_crop_harvesting() -> void:
	# Creates an instance ofharvested crop from preloaded scene
	var tomato_harvest_instance = tomato_harvest_scene.instantiate() as Node2D
	# Sets its position to match current crop position
	tomato_harvest_instance.global_position = global_position
	# Adds harvested crop to scene as child of the crop parent
	get_parent().add_child(tomato_harvest_instance)
	# Removes current crop node, which is replaced with harvested version
	queue_free()
