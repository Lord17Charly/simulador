# Llave-Plantilla.gd
extends Node2D

@export var pecera_id:   int = 2
@export var actuador_id: int = 1
@onready var mqtt_client := get_parent().get_node("MQTTClient")

func _ready() -> void:
	print("🔧 [Llave %d] _ready() arrancado" % actuador_id)
	if not mqtt_client:
		printerr("❌ [Llave %d] No encontré MQTTClient en el padre." % actuador_id)
		return
	print("🔧 [Llave %d] mqtt_client encontrado: %s" % [actuador_id, mqtt_client])
	mqtt_client.client_id = "godot-activator-%d" % actuador_id
	mqtt_client.broker_connected.connect(_on_broker_connected)
	mqtt_client.received_message.connect(_on_received_message)
	mqtt_client.broker_connection_failed.connect(_on_broker_failed)
	mqtt_client.broker_disconnected.connect(_on_broker_disconnected)
	print("🔧 [Llave %d] Señales conectadas" % actuador_id)
	if mqtt_client.brokerconnectmode == mqtt_client.BCM_CONNECTED:
		print("🔧 [Llave %d] broker ya CONNECTED al arrancar" % actuador_id)
		_on_broker_connected()

func _on_broker_connected() -> void:
	print("✅ [Llave %d] _on_broker_connected() recibido" % actuador_id)
	mqtt_client.subscribe("PC/pecera/%d/#" % pecera_id, 0)
	print("🔔 [Llave %d] Suscrito a PC/pecera/%d/#" % [actuador_id, pecera_id])

func _on_received_message(topic: String, payload) -> void:
	print("📥 [Llave %d] _on_received_message → %s : %s" % [actuador_id, topic, payload])
	var parts = topic.split("/")
	if parts.size() == 6 and parts[2].to_int() == pecera_id and parts[4] == "actuador" and parts[5].to_int() == actuador_id:
		var estado = str(payload).to_lower() == "true"
		print("▶️ [Llave %d] payload coincide → %s" % [actuador_id, estado])
		_update_animation(estado)
	else:
		print("⚠️ [Llave %d] mensaje NO corresponde a mi topic" % actuador_id)

func _on_broker_failed() -> void:
	printerr("❌ [Llave %d] fallo al conectar" % actuador_id)

func _on_broker_disconnected() -> void:
	printerr("⚠️ [Llave %d] desconectado" % actuador_id)

func _update_animation(activo: bool) -> void:
	# DEBUG
	print("🎬 [Llave %d] _update_animation(activo=%s)" % [actuador_id, activo])

	if activo:
		print("▶️ [Llave %d] $AnimatedSprite2D.play(\"Abrir-Llave\")" % actuador_id)
		$AnimatedSprite2D.play("Abrir-Llave")
	else:
		print("⏹️ [Llave %d] $AnimatedSprite2D.stop()" % actuador_id)
		$AnimatedSprite2D.stop()

func _input(event):
	if event.is_action_released("ui_accept"):
		print("💡 Trigger manual de animación")
		$AnimatedSprite2D.play("Abrir-Llave")
