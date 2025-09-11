extends Control

var chips: int = 0

@onready var label = $Label

func _ready() -> void:
	chips = 0
	label.text = "Chips: " + str(chips)

func _physics_process(_delta: float) -> void:
	label.text = "Chips: " + str(chips)

func _on_chipsbutten_pressed() -> void:
	chips += 1

func _on_StartBlackjack_pressed() -> void:
	
	var blackjack = get_node("res://scene/main.tscn")
	if blackjack:
		blackjack.bet_amount = chips
		blackjack.start_new_round()
		chips = 0  # reset chips after betting
