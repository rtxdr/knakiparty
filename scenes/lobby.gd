extends Node2D

@onready var mainmenu = $CanvasLayer/MainMenu
@onready var addressentry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry

const Player = preload("res://object/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _on_host_btn_pressed():
	mainmenu.hide()

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())

func _on_join_btn_pressed():
	mainmenu.hide()

	enet_peer.create_client("localhost",PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
