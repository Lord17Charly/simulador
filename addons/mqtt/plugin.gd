@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type(
		"MQTTClient",                # nombre de tu nuevo tipo
		"Node",                      # hereda de Node
		preload("res://addons/mqtt/mqtt.gd"),         # script del cliente MQTT
		preload("res://addons/mqtt/gallina.png")  # icono (puedes usar uno propio)
	)

func _exit_tree():
	remove_custom_type("MQTTClient")
