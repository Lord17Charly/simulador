	# pecera_mediana.gd
extends Node2D

@onready var mqtt_client := $MQTTClient

func _ready() -> void:
	print("🔧 [Pecera] _ready() arrancado")
	# Conectamos al mismo broker al que publica Angular
	var url = "tcp://localhost:1883"
	mqtt_client.connect_to_broker(url)
	print("➡️ [Pecera] connect_to_broker(", url, ") llamado")
