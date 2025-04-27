extends Node
@export var mqtt_path: NodePath
@onready var mqtt = get_node_or_null(mqtt_path)
func _ready():
	if mqtt == null:
		printerr("❌ Nodo MQTT no asignado o path incorrecto")
		
	mqtt.client_id = "godot"
		# Conectar señales (Godot 4)
	mqtt.broker_connected.connect(_on_broker_connected)
	mqtt.received_message.connect(_on_received_message)
	mqtt.broker_connection_failed.connect(_on_broker_failed)
	mqtt.broker_disconnected.connect(_on_broker_disconnected)
	# Iniciar conexión al brokerdocke
	var ok = mqtt.connect_to_broker('192.168.0.0')
	if not ok:
		print("No pude iniciar la conexión MQTT.")

func _on_broker_connected():
	print("✅ Conectado al broker MQTT")
	mqtt.subscribe("PC/pecera1/#", 0)
	#var random_value = str(randi() % 100)  Número aleatorio entre 0 y 99, convertido a String
	#mqtt.publish("PC/pecera1/nivelAgua/sensor/1", random_value, false, 0)


func _on_received_message(topic: String, payload):
	# payload ya es String, úsalo directamente:
	print("📥 Mensaje en [%s]: %s" % [topic, payload])

func _on_broker_failed():
	print("❌ Conexión fallida al broker")

func _on_broker_disconnected():
	print("⚠️ Desconectado del broker")
func forward_mqtt_message(topic: String, payload: String, retain: bool=false, qos: int=0) -> void:
	if mqtt == null:
		push_error("❌ Cliente MQTT no inicializado")
		return
		# Verifica la conexión al broker (BCM_CONNECTED == 20)
	if mqtt.brokerconnectmode == mqtt.BCM_CONNECTED:
		mqtt.publish(topic, payload, retain, qos)
		print("🔄 Mensaje reenviado vía MQTT:", topic, payload)
	else:
		push_error("❌ No conectado al broker. Imposible reenviar mensaje.")
