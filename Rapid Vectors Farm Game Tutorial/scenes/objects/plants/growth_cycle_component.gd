class_name GrowthCycleComponent
extends Node

# Stores current state of crop growth, deafult state - Germination
@export var current_growth_state: DataTypes.GrowthStates = DataTypes.GrowthStates.Germination
# Defines the number of days required for crop to be ready to harvest, deafult - 7 days
@export_range(5, 365) var days_until_harvest: int = 7

signal crop_maturity
signal crop_harvesting

# Stores info about crop being watered, day when growth starts and current ingame day
var is_watered: bool
var starting_day: int
var current_day: int


func _ready() -> void:
	# Connects time_tick_day signal with on_time_tick func
	DayAndNightCycleManager.time_tick_day.connect(on_time_tick_day)

# Called every time time_tick_day signal is emited
func on_time_tick_day(day: int) -> void:
	# Checks if crop is watered before starting growth cycle
	if is_watered:
		# If growth hasn't started yet, it sets starting_day to current day
		if starting_day == 0:
			starting_day = day
		# Calls funtions to update growth and harvesting progress
		growth_state(starting_day, day)
		harvest_state(starting_day, day)

# Manages growth stages
func growth_state(starting_day: int, current_day: int):
	# If crop has already reached maturity, it exits
	if current_growth_state == DataTypes.GrowthStates.Maturity:
		return
	
	# Defines number of growth stages
	var num_of_states = 5
	
	# Calculates which state crop is currently in
	var growth_days_passed = (current_day - starting_day) % num_of_states
	# Calculates index in enum of current crop state
	var state_index = growth_days_passed % num_of_states + 1
	
	current_growth_state = state_index
	
	# Fetches name of growth state and prints it for debugging
	#var name = DataTypes.GrowthStates.keys()[current_growth_state]
	#print("Current growth state:", name)
	
	# If maturity state is reached, emits crop_maturity signal
	if current_growth_state == DataTypes.GrowthStates.Maturity:
		crop_maturity.emit()


func harvest_state(starting_day: int, current_day: int):
	# If crop is already inharvesting state, it exits
	if current_growth_state == DataTypes.GrowthStates.Harvesting:
		return
	
	# Calculates how many days have passed since crop started growing
	var days_passed = (current_day - starting_day) % days_until_harvest
	
	# If required days for harvesting have passed, updates current state to harvesting and emits crop_harvesting signal
	if days_passed == days_until_harvest -1:
		current_growth_state = DataTypes.GrowthStates.Harvesting
		crop_harvesting.emit()

# Returns current growth state, usually called from other stripts
func get_current_growth_state() -> DataTypes.GrowthStates:
	return current_growth_state
