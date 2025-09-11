extends Control

var chips = 0


func _ready() -> void:
	chips = 0
	
	
func _physics_process(delta: float) -> void:
	$Label.text = "chips : " + str(chips)
	


func _on_chipsbutten_pressed() -> void:
	chips += 1
	
