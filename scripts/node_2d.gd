extends Node

enum GameState { PLAYER_TURN, DEALER_TURN, ROUND_OVER }
var game_state = GameState.PLAYER_TURN
var deck = []
var player_hand = []
var dealer_hand = []
var player_total = 0
var dealer_total = 0
var bet_amount = 10

@onready var player_cards = $PlayerCards
@onready var dealer_cards = $DealerCards

func _ready():
	start_new_round()
	
	
	$buttons/HitButton.pressed.connect(_on_Hit_pressed)
	$buttons/StandButton.pressed.connect(_on_Stand_pressed)
	$buttons/DoubleButton.pressed.connect(_on_Double_pressed)
	
func start_new_round():
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
	
	deal_card_to_player()
	deal_card_to_dealer(true)
	deal_card_to_player()
	deal_card_to_dealer()

func generate_deck():
	var suits = ["♠","♥","♦","♣"]
	var ranks = ["A","2","3","4","5","6","7","8","9","10","J","Q","K"]
	var new_deck = []
	for s in suits:
		for r in ranks:
			new_deck.append({"rank": r, "suit": s})
	return new_deck

func shuffle_deck():
	deck.shuffle()

func deal_card_to_player():
	var card = deck.pop_front()
	player_hand.append(card)
	update_totals()
	show_card(card, player_cards)

func deal_card_to_dealer(hidden=false):
	var card = deck.pop_front()
	dealer_hand.append(card)
	update_totals()
	show_card(card, dealer_cards, hidden)

func update_totals():
	player_total = calculate_total(player_hand)
	dealer_total = calculate_total(dealer_hand)

func calculate_total(hand):
	var total = 0
	var aces = 0
	for card in hand:
		var rank = card.rank
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

func show_card(card: Dictionary, container: HBoxContainer, hidden=false):
	var sprite = Sprite2D.new()
	var path = ""
	
	if hidden:
		path = "res://assets/back.png"
	else:
		var rank = str(card.rank)
		var suit = ""
		match card.suit:
			"♠": suit = "spades"
			"♥": suit = "hearts"
			"♦": suit = "diamonds"
			"♣": suit = "clubs"
		path = "res://assets/card_%s_%s.png" % [rank, suit]
	
	if ResourceLoader.exists(path):
		var tex = ResourceLoader.load(path)
		if tex is Texture2D:
			sprite.texture = tex
			sprite.centered = true
			sprite.scale = Vector2(0.1, 0.1)   #cards scale
	else:
		print("not found :", path)
	
	container.add_child(sprite)


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
	dealer_cards.get_child(0).text = dealer_hand[0].rank + dealer_hand[0].suit
	while dealer_total < 17:
		deal_card_to_dealer()
	end_round()

func end_round():
	game_state = GameState.ROUND_OVER
	if player_total > 21:
		print("player busted ")
	elif dealer_total > 21 or player_total > dealer_total:
		print("Player wins")
	elif player_total == dealer_total:
		print("tie")
	else:
		print("dealer win")
