class_name ButtonSoundManager

extends Node

var playback:AudioStreamPlaybackPolyphonic

@export var button_sound_groups : Array[ButtonSoundGroup]


func _enter_tree() -> void:
	# Create an audio player
	var player = AudioStreamPlayer.new()
	add_child(player)

	# Create a polyphonic stream so we can play sounds directly from it
	var stream = AudioStreamPolyphonic.new()
	stream.polyphony = 32
	player.stream = stream
	player.play()
	# Get the polyphonic playback stream to play sounds
	playback = player.get_stream_playback()

	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node:Node) -> void:
	if node is Button:
		for a in button_sound_groups:
			if a.group == (node as Button).button_group:
				node.mouse_entered.connect(playback.play_stream(a.hover_sound, 0, 0, randf_range(0.9, 1.1)))
				node.pressed.connect(playback.play_stream(a.click_sound, 0, 0, randf_range(0.9, 1.1)))


