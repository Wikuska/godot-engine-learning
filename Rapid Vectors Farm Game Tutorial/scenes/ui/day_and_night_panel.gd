extends Control

@onready var day_label: Label = $DayPanel/MarginContainer/DayLabel
@onready var time_label: Label = $TimePanel/MarginContainer/TimeLabel

@export var normal_speed: int = 5
@export var fast_speed: int = 100
@export var cheetah_speed: int = 200


func _ready() -> void:
	# Connect time_tick signal emition with on_time_tick function
	DayAndNightCycleManager.time_tick.connect(on_time_tick)


func on_time_tick(day:int, hour:int, minute:int) -> void:
	# Update panel labels with vars passed from signal
	day_label.text = "Day " + str(day)
	time_label.text = "%02d:%02d" % [hour, minute]


# On speed button press set game_speed to button corresponding value
func _on_normal_speed_button_pressed() -> void:
	DayAndNightCycleManager.game_speed = normal_speed


func _on_fast_speed_button_pressed() -> void:
	DayAndNightCycleManager.game_speed = fast_speed


func _on_cheetah_speed_button_pressed() -> void:
	DayAndNightCycleManager.game_speed = cheetah_speed
