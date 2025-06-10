extends Node2D  # Nodo que representa el agua y sube de nivel

@export var llave_path: NodePath  # Ruta al nodo llave.gd
@onready var llave = get_node_or_null(llave_path) as Node
@onready var sprite = $AnimatedSprite2D
@onready var col_shape = $CollisionShape2D
var tween: Tween

# Altura máxima deseada (en píxeles) y duración de la animación (segundos)
@export var altura_objetivo: float = 200.0
@export var duracion_anim: float = 2.0

func _ready():
	if llave == null:
		push_error("❌ Nodo Llave no encontrado en 'llave_path'")
		return

	# Crear y añadir el Tween
	tween = Tween.new()
	add_child(tween)

	# Conectar la señal que emite la llave al abrirse
	llave.connect("llave_abierta", Callable(self, "_on_llave_abierta"))

func _on_llave_abierta() -> void:
	# Calcula la escala Y necesaria para alcanzar la altura_objetivo
	var textura_h = sprite.frames.get_frame(sprite.animation, 0).get_size().y
	var scale_y_target = altura_objetivo / textura_h

	# Detener animaciones previas y configurar nueva
	tween.kill_all()
	tween.tween_property(sprite, "scale:y", scale_y_target, duracion_anim)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Ajustar CollisionShape2D (asumiendo RectangleShape2D)
	var rect_shape = col_shape.shape as RectangleShape2D
	var target_extents_y = altura_objetivo * 0.5  # extents = mitad de altura
	tween.tween_property(rect_shape, "extents:y", target_extents_y, duracion_anim)\
		 .set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
