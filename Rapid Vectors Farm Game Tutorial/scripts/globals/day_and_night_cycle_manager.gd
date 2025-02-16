extends Node

# Number of minutes in a full day (1440)
const MINUTES_PER_DAY: int = 24 * 60
# Number of minutes in an hour (60)
const MINUTES_PER_HOUR: int = 60
# Angle step for game time progression
const GAME_MINUTE_DURATION: float = TAU / MINUTES_PER_DAY

# Multiplier for how fast time passes (default = 5x)
var game_speed: float = 5.0

# Start time for the game
var initial_day: int = 1
var initial_hour: int = 12
var initial_minute: int = 30

# Tracks the total game time
var time: float = 0.0
# Stores the latest time updates to detect changes
var current_minute: int = -1
var current_day: int = 0

signal game_time(time: float)
signal time_tick(day: int, hour: int, minute: int)
signal time_tick_day(day: int)


func _ready() -> void:
	# Calls set_initial_time to set game clock at specified start time
	set_initial_time()


func _process(delta: float) -> void:
	# Updates time every frame
	time += delta * game_speed * GAME_MINUTE_DURATION
	# Emits game_time so other scripts can listen for time changes
	game_time.emit(time)
	# Calls recalculate_time to check if day or minute has changed
	recalculate_time()


func set_initial_time() -> void:
	# Converts starting day, hour and minute into total minutes
	var initial_total_minutes = initial_day * MINUTES_PER_DAY + (initial_hour * MINUTES_PER_HOUR) + initial_minute
	# Calculates the corresponding time value
	time = initial_total_minutes * GAME_MINUTE_DURATION


func recalculate_time() -> void:
	# Converts time into corresponding days and minutes
	var total_minutes: int = int(time / GAME_MINUTE_DURATION)
	var day: int = int(total_minutes / MINUTES_PER_DAY)
	var current_day_minutes: int = total_minutes % MINUTES_PER_DAY
	var hour: int = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute: int = int(current_day_minutes % MINUTES_PER_HOUR)
	
	# When new minute starts
	if current_minute != minute:
		# Sets it as curent minute
		current_minute = minute
		# Emits time_tick signal
		time_tick.emit(day, hour, minute)
	
	# When new day starts
	if current_day != day:
		# Set it as current day
		current_day = day
		# Emits time_tick_day signal
		time_tick_day.emit(day)
