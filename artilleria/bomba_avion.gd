extends Area2D

@export var velocidad_caida: float = 10.0
@export var poder_destruccion: int = 50
@export var radio_destruccion: float = 50.0
@export var escala_inicial: Vector2 = Vector2(0.2, 0.2)  # Escala inicial más grande
@export var escala_final: Vector2 = Vector2(0.01, 0.01)  # Escala final más pequeña

# Variables internas
var distancia_recorrida: float = 0.0
var avion_padre: Node = null  # Referencia al avión que lanzó la bomba

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	set_scale(escala_inicial)  # Configura el tamaño inicial

func lanzar_bomba(pos_inicial: Vector2, avion: Node):
	position = pos_inicial  # Asegura que la bomba comience en la posición del avión
	avion_padre = avion

func _process(delta):
	# Movimiento vertical hacia abajo
	var desplazamiento = Vector2(0, velocidad_caida * delta)
	position += desplazamiento
	distancia_recorrida += desplazamiento.length()

	# Ajusta la escala durante la caída
	var progreso = distancia_recorrida / radio_destruccion
	set_scale(lerp(escala_inicial, escala_final, min(progreso, 1.0)))

	# Verificar si la bomba debe explotar
	if distancia_recorrida >= radio_destruccion:
		explotar()

func _on_body_entered(body):
	if body.is_in_group("tanques") or body.is_in_group("enemigos"):
			if body != avion_padre:
				body.recibir_dano(poder_destruccion)
				lanzar_explosion(position, radio_destruccion, body)  # Pasar el objeto impactado
	explotar()

func explotar():
	# Añade efectos de explosión (sonido, partículas, etc.)
	lanzar_explosion(position, poder_destruccion)
	queue_free()  # Destruye la bomba

func lanzar_explosion(posicion, poder, objeto_afectado = null):
	var explosion_scene = preload("res://explosion.tscn").instantiate()
	if objeto_afectado != null:
		# Explosión sigue al tanque o enemigo
		objeto_afectado.add_child(explosion_scene)
		explosion_scene.position = Vector2.ZERO
	else:
		# Explosión independiente en el mundo
		explosion_scene.position = posicion
		get_tree().current_scene.add_child(explosion_scene)
	explosion_scene.iniciar_explosion(poder)
