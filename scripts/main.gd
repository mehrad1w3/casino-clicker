extends Node2D

func _ready() -> void:
	#on start
	$Clicker.show()
	$blackjack.hide()
	$Clicker/StartBlackjack.connect("pressed", Callable(self, "_on_start_blackjack_pressed"))
	
func _on_start_blackjack_pressed():
	var chips = $Clicker.chips   	
		
	$Clicker.hide()
	$blackjack.show()
	$blackjack.bet_amount = $Clicker.chips   # chips from Clicker
	$blackjack.start_new_round()
