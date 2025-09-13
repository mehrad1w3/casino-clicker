extends Control

var chips: int = 0

@onready var label = $Label

func _ready() -> void:
	
	label.text = "Chips: " + str(chips)

func _physics_process(_delta: float) -> void:
	label.text = "Chips: " + str(chips)

func _on_chipsbutten_pressed() -> void:
	chips += 1

func _on_start_blackjack_pressed() -> void:
	var blackjack_scene = preload("res://scene/blackjack.tscn")
	var blackjack = blackjack_scene.instantiate()
	get_tree().root.add_child(blackjack)   # main tree
	blackjack.bet_amount = chips
	blackjack.start_new_round()
