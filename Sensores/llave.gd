extends Node

# Puedes cambiar desde el Inspector:
@export var mqtt_path: NodePath
@export var broker_url: String = "tcp://192.168.0.22"
@export var categoria: String = "calidadAgua"     # misma categoría que usa Angular
@export var pecera_id: int = 2                     # número de pecera editable
@export var actuador_id: int = 1                   # número de termómetro/llave editable

@onready var mqtt = get_node_or_null(mqtt_path)
var activator_states: Dictionary = {}

func _ready():
	if mqtt == null:
		printerr("❌ MQTTClient no asignado en mqtt_path")
		return

	# Configura el cliente MQTT
	mqtt.client_id = "godot-activator"
	mqtt.broker_connected.connect(_on_broker_connected)
	mqtt.received_message.connect(_on_received_message)
	mqtt.broker_connection_failed.connect(_on_broker_failed)
	mqtt.broker_disconnected.connect(_on_broker_disconnected)

	var ok = mqtt.connect_to_broker(broker_url)
	if not ok:
		printerr("❌ No pude conectar al broker:", broker_url)

func _on_broker_connected():
	print("✅ Llave: Conectado al broker")

	# Construyo el topic usando pecera_id, categoría y actuador_id
	#   Ejemplo: "PC/pecera/2/calidadAgua/actuador/1"
	var topic = "PC/pecera/%d/%s/actuador/%d" % [pecera_id, categoria, actuador_id]
	mqtt.subscribe(topic, 0)
	print("🔔 Llave: Suscrito a", topic)

func _on_received_message(topic: String, payload):
	# Desmenuzo el topic para validar que sea para esta pecera/categoría/actuador
	var parts = topic.split("/") 
	# parts = ["PC","pecera","<pecera_id>","<categoria>","actuador","<id>"]
	if parts.size() == 6 \
	and parts[0] == "PC" \
	and parts[1] == "pecera" \
	and parts[2].to_int() == pecera_id \
	and parts[3] == categoria \
	and parts[4] == "actuador" \
	and parts[5].to_int() == actuador_id:
		
		var act_id = parts[5]
		var new_state = payload.to_lower() == "true"
		if !activator_states.has(act_id) or activator_states[act_id] != new_state:
			activator_states[act_id] = new_state
			print("🔑 Activador [", act_id, "] cambiado a:", new_state)
			_update_animation(new_state)
		else:
			print("ℹ️ Activador [", act_id, "] ya en estado:", new_state)
	else:
		# Otros mensajes que pudieran llegar (por otra pecera, otro actuador, etc.)
		print("📥 Recibido en [%s]: %s" % [topic, payload])

func _on_broker_failed():
	printerr("❌ Llave: Conexión fallida al broker")

func _on_broker_disconnected():
	printerr("⚠️ Llave: Desconectado del broker")

func _update_animation(activate: bool) -> void:
	if activate:
		$llaveAnimatedSprite2D.play("open")
	else:
		$llaveAnimatedSprite2D.stop()

