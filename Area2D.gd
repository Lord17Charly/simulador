extends Area2D

@export var main_path: NodePath            # ruta al nodo Main
@export var publish_topic: String = "PC/pecera1/nivelAgua/sensor/1"
@onready var main_node = get_node_or_null(main_path)
@onready var timer = $flujo_agua_Timer           # asume un Timer hijo

func _ready():
	if main_node == null:
		push_error("❌ main_node no encontrado. Revisa `main_path`.")
		return

	timer.one_shot = false
	timer.autostart = false

	body_entered.connect(Callable(self, "_on_body_entered"))
	body_exited.connect(Callable(self, "_on_body_exited"))
	timer.timeout.connect(Callable(self, "_on_timer_timeout"))

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("▶️ Cuerpo entró. Iniciando envíos...")
		timer.start

func _on_body_exited(body):
	if body.is_in_group("player"):
		print("⏸️ Cuerpo salió. Deteniendo envíos...")
		timer.stop()

func _on_timer_timeout():
	var random_value = str(randi() % 100)
	main_node.forward_mqtt_message(publish_topic, random_value, false, 0)
	print("🔄 DetectorArea publicó:", publish_topic, "→", random_value)
