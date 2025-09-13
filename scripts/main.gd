extends Node2D

func _ready() -> void:
	# on start
	$Clicker.show()
	$blackjack.hide()
	$Clicker/StartBlackjack.connect("pressed", Callable(self, "_on_start_blackjack_pressed"))

	
	$blackjack.round_finished.connect(_on_blackjack_round_finished)

func _on_start_blackjack_pressed():
	var chips = $Clicker.chips
	$Clicker.hide()
	$blackjack.show()
	$blackjack.bet_amount = $Clicker.chips   # chips from Clicker
	$blackjack.start_new_round()

func _on_blackjack_round_finished(chips_won: int) -> void:
	
	$Clicker.chips += chips_won
	

	$Clicker.show()
	$blackjack.hide()
	
	
	
