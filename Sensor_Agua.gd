extends Node

@export var mqtt_path: NodePath
@export var broker_url: String = "tcp://localhost:1883"
@export var publish_topic: String = "PC/pecera/1/temperatura/sensor/1"

@onready var mqtt = get_node_or_null(mqtt_path)

func _ready():
	if mqtt == null:
		printerr("❌ MQTTClient no asignado")
		return

	mqtt.client_id = "godot-publisher"
	mqtt.broker_connected.connect(_on_broker_connected)
	mqtt.broker_connection_failed.connect(_on_broker_failed)
	mqtt.broker_disconnected.connect(_on_broker_disconnected)

	var ok = mqtt.connect_to_broker(broker_url)
	if not ok:
		printerr("❌ No pude iniciar la conexión MQTT.")

func _on_broker_connected():
	print("✅ Conectado al broker, iniciando envíos...")
	# Opcional: lanza un temporizador para enviar datos periódicamente
	var timer = Timer.new()
	timer.wait_time = 2.0    # cada 2 segundos
	timer.one_shot = false
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	# Simula un valor de temperatura
	var temp = randi() % 30 + 15   # entre 15 y 44
	var payload = str(temp)        # conviértelo a String
	mqtt.publish(publish_topic, payload, false, 0)
	print("🔄 Publicado:", publish_topic, "→", payload)

func _on_broker_failed():
	printerr("❌ Sensor/NivelAgua Conexión fallida al broker")

func _on_broker_disconnected():
	printerr("⚠️ Sensor/NivelAgua Desconectado del broker")
