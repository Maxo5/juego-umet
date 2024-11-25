extends Area2D

@export var velocidad: float = 200.0
@export var alcance: float = 0.0  # Máxima distancia permitida para la bomba
@export var poder_destruccion: int = 50
@export var radio_destruccion: float = 50.0
@export var desfase_posicion: float = 10.0  # Ajuste para que la bomba salga un poco adelante
@export var altura_maxima: float = 1  # Altura máxima simulada


# Variables internas
var potencia: float = 0.0
var distancia_recorrida: float = 0.0
var direccion: Vector2 = Vector2.ZERO
var tanque_padre: Node = null  # Referencia al nodo del tanque que disparó la bomba

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	set_deferred("monitoring", false)  # Desactiva colisiones inicialmente

func lanzar_bomba(dir: Vector2, potencia_disparo: float):
	if potencia_disparo <= 0.0:
		return  # Evitar valores negativos o cero
	direccion = dir.normalized()
	distancia_recorrida = 0.0
	position += direccion * desfase_posicion
	potencia = min(potencia_disparo, alcance)  # Limita la potencia al alcance máximo

func _process(delta):
	var desplazamiento = direccion * velocidad * delta
	position += desplazamiento
	distancia_recorrida += desplazamiento.length()

	# Simula la trayectoria parabólica de la bomba
	var altura_actual = calcular_altura(distancia_recorrida, potencia)
	set_scale(Vector2(0.1, 0.1) * (1 + altura_actual / altura_maxima))  # Ajusta la escala

	# Activa colisión cerca del final
	if distancia_recorrida >= potencia - (radio_destruccion / 2):
		set_deferred("monitoring", true)

	# Si alcanza la distancia objetivo (potencia), explota
	if distancia_recorrida >= potencia:
		explotar()

func calcular_altura(distancia, potencia) -> float:
	var mitad_potencia = potencia / 2.0
	if distancia <= mitad_potencia:
		return lerp(0.0, altura_maxima, distancia / mitad_potencia)
	else:
		return lerp(altura_maxima, 0.0, (distancia - mitad_potencia) / mitad_potencia)

func _on_body_entered(body):
	if distancia_recorrida >= potencia - (radio_destruccion / 2):
		if body.is_in_group("tanques") or body.is_in_group("enemigos"):
			if body != tanque_padre:
				body.recibir_dano(poder_destruccion)
				lanzar_explosion(position, radio_destruccion, body)  # Pasar el objeto impactado
	explotar()



func explotar():
	# Aquí podrías añadir efectos de explosión (sonido, partículas, etc.)
	emit_signal("bomba_explotada")  # Emitir señal al explotar
	lanzar_explosion(position,radio_destruccion)
	queue_free()  # Destruye la bomba



func lanzar_explosion(posicion, poder, objeto_afectado = null):
	var explosion_scene = preload("res://explosion.tscn").instantiate()
	if objeto_afectado != null:
		# Hacer que la explosión sea hija del tanque o enemigo impactado
		objeto_afectado.add_child(explosion_scene)
		explosion_scene.position = Vector2.ZERO  # Centrar la explosión en el objeto
	else:
		# Añadir la explosión al árbol principal si no hay un objeto afectado
		explosion_scene.position = posicion
		get_tree().current_scene.add_child(explosion_scene)
	# Iniciar la explosión
	explosion_scene.iniciar_explosion(poder)
