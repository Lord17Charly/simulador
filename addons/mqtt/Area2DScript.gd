extends Area2D  # Area2D detecta cuerpos que entran y salen del área en 2D :contentReference[oaicite:0]{index=0}

@export var main_path: NodePath  # Ruta al nodo Main con forward_mqtt_message() :contentReference[oaicite:1]{index=1}
@onready var main_node = get_node_or_null(main_path)  # Obtiene el nodo o null si no existe :contentReference[oaicite:2]{index=2}
@onready var timer = $Timer  # Asume que has añadido un nodo Timer como hijo en la escena :contentReference[oaicite:3]{index=3}

func _ready():
	if main_node == null:
		push_error("❌ main_node no encontrado. Revisa `main_path` en el Inspector.")  # Evita errores si falta la referencia
		return
	# Configuración del Timer: no es one_shot y no arranca automáticamente :contentReference[oaicite:4]{index=4}
	timer.one_shot = false
	timer.autostart = false
	# Conectar señales con Callable en Godot 4 :contentReference[oaicite:5]{index=5}
	body_entered.connect(Callable(self, "_on_body_entered"))
	body_exited.connect(Callable(self, "_on_body_exited"))
	timer.timeout.connect(Callable(self, "_on_timer_timeout"))

func _on_body_entered(body):
	if body.is_in_group("player"):  # Solo reacciona al jugador :contentReference[oaicite:6]{index=6}
		timer.start()  # Arranca el envío periódico mientras permanezca dentro

func _on_body_exited(body):
	if body.is_in_group("player"):  # Cuando el jugador sale del área :contentReference[oaicite:7]{index=7}
		timer.stop()  # Detiene el envío periódico

func _on_timer_timeout():
	# Define tópico y mensaje
	var topic = "metest/sala"
	var message = "Player sigue dentro del area"
	# Reenvía el mensaje usando la función en Main :contentReference[oaicite:8]{index=8}
	main_node.forward_mqtt_message(topic, message, false, 0)
	print("🔄 Mensaje reenviado en timer:", topic, message)  # Confirmación en consola
