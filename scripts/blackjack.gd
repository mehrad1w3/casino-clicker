extends Node

enum GameState { PLAYER_TURN, DEALER_TURN, ROUND_OVER }
var game_state = GameState.PLAYER_TURN
var deck: Array = []
var player_hand: Array = []
var dealer_hand: Array = []
var player_total: int = 0
var dealer_total: int = 0
var bet_amount: int = 10

@onready var player_cards = $CenterContainer/VBoxContainer/PlayerCards
@onready var dealer_cards = $CenterContainer/VBoxContainer/DealerCards

func _ready():
	player_cards.add_theme_constant_override("separation", 20)
	dealer_cards.add_theme_constant_override("separation", 20)

	start_new_round()

	$CenterContainer/VBoxContainer/buttons/HitButton.pressed.connect(_on_Hit_pressed)
	$CenterContainer/VBoxContainer/buttons/StandButton.pressed.connect(_on_Stand_pressed)
	$CenterContainer/VBoxContainer/buttons/DoubleButton.pressed.connect(_on_Double_pressed)


func start_new_round():
	print("Bet for this round:", bet_amount)
	deck = generate_deck()
	shuffle_deck()
	player_hand.clear()
	dealer_hand.clear()
	player_total = 0
	dealer_total = 0

	for c in player_cards.get_children():
		c.queue_free()
	for c in dealer_cards.get_children():
		c.queue_free()

	game_state = GameState.PLAYER_TURN

	# Deal cards
	deal_card_to_player()
	deal_card_to_dealer(true) # hidden card
	deal_card_to_player()
	deal_card_to_dealer()


func generate_deck() -> Array:
	var suits = ["♠","♥","♦","♣"]
	var ranks = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
	var new_deck: Array = []
	for s in suits:
		for r in ranks:
			new_deck.append({"rank": r, "suit": s})
	return new_deck


func shuffle_deck():
	deck.shuffle()


func deal_card_to_player():
	if deck.is_empty(): return
	var card = deck.pop_front()
	player_hand.append(card)
	update_totals()
	show_card(card, player_cards, false)


func deal_card_to_dealer(hidden := false):
	if deck.is_empty(): return
	var card = deck.pop_front()
	dealer_hand.append(card)
	update_totals()
	show_card(card, dealer_cards, hidden)


func update_totals():
	player_total = calculate_total(player_hand)
	dealer_total = calculate_total(dealer_hand)


func calculate_total(hand: Array) -> int:
	var total = 0
	var aces = 0
	for card in hand:
		var rank = card["rank"]
		if rank in ["J","Q","K"]:
			total += 10
		elif rank == "A":
			total += 11
			aces += 1
		else:
			total += int(rank)
	while total > 21 and aces > 0:
		total -= 10
		aces -= 1
	return total


func show_card(card: Dictionary, container: HBoxContainer, hidden := false):
	var tex_rect = TextureRect.new()
	tex_rect.expand = true
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.custom_minimum_size = Vector2(120, 180)  # fixed/control size in the HBox

	var path: String = ""
	if hidden:
		path = "res://assets/back.png"
	else:
		var rank = str(card["rank"])
		var suit_name = ""
		if card["suit"] == "♠":
			suit_name = "spades"
		elif card["suit"] == "♥":
			suit_name = "hearts"
		elif card["suit"] == "♦":
			suit_name = "diamonds"
		elif card["suit"] == "♣":
			suit_name = "clubs"
		path = "res://assets/card_%s_%s.png" % [rank, suit_name]

	if ResourceLoader.exists(path):
		var tex = ResourceLoader.load(path)
		if tex is Texture2D:
			tex_rect.texture = tex
	else:
		print("❌ Card image not found:", path)

	# Add to the HBoxContainer — TextureRect is a Control, so HBox will lay them out side-by-side
	container.add_child(tex_rect)


func reveal_dealer_hidden_card():
	if dealer_cards.get_child_count() > 0:
		var tex_rect = dealer_cards.get_child(0) as TextureRect
		if tex_rect and dealer_hand.size() > 0:
			var first_card = dealer_hand[0]
			var rank = str(first_card["rank"])
			var suit_name = ""

			if first_card["suit"] == "♠":
				suit_name = "spades"
			elif first_card["suit"] == "♥":
				suit_name = "hearts"
			elif first_card["suit"] == "♦":
				suit_name = "diamonds"
			elif first_card["suit"] == "♣":
				suit_name = "clubs"

			var path = "res://assets/card_%s_%s.png" % [rank, suit_name]
			if ResourceLoader.exists(path):
				tex_rect.texture = load(path)


func _on_Hit_pressed():
	if game_state == GameState.PLAYER_TURN:
		deal_card_to_player()
		if player_total > 21:
			end_round()


func _on_Stand_pressed():
	if game_state == GameState.PLAYER_TURN:
		game_state = GameState.DEALER_TURN
		dealer_play()


func _on_Double_pressed():
	if game_state == GameState.PLAYER_TURN:
		bet_amount *= 2
		deal_card_to_player()
		if player_total <= 21:
			game_state = GameState.DEALER_TURN
			dealer_play()
		else:
			end_round()


func dealer_play():
	reveal_dealer_hidden_card()

	while dealer_total < 17:
		deal_card_to_dealer()

	end_round()


func end_round():
	game_state = GameState.ROUND_OVER
	if player_total > 21:
		print("❌ Player busted")
	elif dealer_total > 21 or player_total > dealer_total:
		print("✅ Player wins")
	elif player_total == dealer_total:
		print("➖ Tie")
	else:
		print("🏆 Dealer wins")
