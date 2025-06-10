extends Node

@export var mqtt_path: NodePath
@onready var mqtt = get_node_or_null(mqtt_path)

func _ready():
	if mqtt == null:
		printerr("❌ Nodo MQTT no asignado o path incorrecto")
		return

	mqtt.client_id = "godot"
	mqtt.broker_connected.connect(_on_broker_connected)
	mqtt.received_message.connect(_on_received_message)
	mqtt.broker_connection_failed.connect(_on_broker_failed)
	mqtt.broker_disconnected.connect(_on_broker_disconnected)

	var ok = mqtt.connect_to_broker("tcp://localhost:1883")
	if not ok:
		printerr("❌ No pude iniciar la conexión MQTT.")

func _on_broker_connected():
	print("✅ Conectado al broker MQTT")
	mqtt.subscribe("PC/pecera1/temperatura/actuador/1", 0)

func _on_received_message(topic: String, payload):
	print("📥 Mensaje en [%s]: %s" % [topic, payload])

func _on_broker_failed():
	print("❌ Conexión fallida de Termometro al broker")

func _on_broker_disconnected():
	print("⚠️ Desconectado Termometro del broker")

# Este método es llamado por el Area2D para reenviar cualquier mensaje
func forward_mqtt_message(topic: String, payload: String, retain: bool=false, qos: int=0) -> void:
	if mqtt == null:
		push_error("❌ Cliente MQTT no inicializado")
		return
	if mqtt.brokerconnectmode == mqtt.BCM_CONNECTED:
		mqtt.publish(topic, payload, retain, qos)
		print("🔄 Mensaje reenviado vía MQTT:", topic, payload)
	else:
		push_error("❌ No conectado al broker. Imposible reenviar mensaje.")

