# SensorArea.gd
extends Area2D

# ---------------------------------------------------
# CONFIGURACIÓN DESDE INSPECTOR
# ---------------------------------------------------
@export var mqtt_path: NodePath    = "../MQTTClient"
@export var broker_url: String     = ""  # ¡ya no lo usamos aquí!
@export var pecera_id:   int       = 2
@export var categoria:   String    = "nivelAgua"
@export var sensor_id:   int       = 1
@export var nodo_id:     int       = 1

# ---------------------------------------------------
# NODOS Y VARIABLES INTERNAS
# ---------------------------------------------------
@onready var mqtt_client: Node     = get_node_or_null(mqtt_path)
@onready var timer:        Timer    = $Timer

func _ready() -> void:
	if mqtt_client == null:
		printerr("❌ Sensor: MQTTClient no encontrado en ", mqtt_path)
		return

	# Solo ajustamos client_id y señales; la conexión ya la hizo el padre.
	var client_id_unico = "godot-sensor-%d-%d" % [sensor_id, nodo_id]
	mqtt_client.client_id = client_id_unico
	print("🚀 Sensor: client_id → ", client_id_unico)

	mqtt_client.broker_connected.connect(_on_broker_connected)
	mqtt_client.broker_connection_failed.connect(_on_broker_failed)
	mqtt_client.broker_disconnected.connect(_on_broker_disconnected)

	# Configuramos el Timer y las señales de área
	timer.one_shot = false
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)

# ---------------------------------------------------
# CALLBACKS DEL BROKER MQTT
# ---------------------------------------------------
func _on_broker_connected() -> void:
	print("✅ Sensor: broker ya conectado (lo hizo el padre)")

func _on_broker_failed() -> void:
	printerr("❌ Sensor: fallo conexión al broker")

func _on_broker_disconnected() -> void:
	printerr("⚠️ Sensor: desconectado del broker")

# ---------------------------------------------------
# DETECCIÓN EN EL ÁREA 2D
# ---------------------------------------------------
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		print("🔔 Sensor: jugador entró, arrancando timer")
		timer.start()

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		print("🔕 Sensor: jugador salió, deteniendo timer")
		timer.stop()

# ---------------------------------------------------
# ENVÍO DE DATOS PERIÓDICOS
# ---------------------------------------------------
func _on_timer_timeout() -> void:
	var topic = "PC/pecera/%d/%s/sensor/%d/%d" % [
		pecera_id, categoria, sensor_id, nodo_id
	]
	var value = str(randi() % 100)
	mqtt_client.publish(topic, value, false, 0)
	print("🔄 Sensor: publicado → ", topic, value)

# ---------------------------------------------------
# MÉTODO AUXILIAR PARA REENVIAR MENSAJES
# ---------------------------------------------------
func forward_mqtt_message(topic: String, smsg, retain := false, qos := 0) -> void:
	if mqtt_client.brokerconnectmode == mqtt_client.BCM_CONNECTED:
		mqtt_client.publish(topic, smsg, retain, qos)
		print("🔁 Sensor: reenvío → ", topic, smsg)
	else:
		push_error("❌ Sensor: no conectado, no se puede reenviar.")
