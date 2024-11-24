extends "res://tropas/terrestre.gd"

@export var velocidad: float = 100.0
@export var alcance: float = 1300.0  # Máxima distancia permitida para el avión
@export var altura_maxima: float = 2.0  # Altura máxima simulada

# Variables internas
var distancia_recorrida: float = 0.0
var direccion: Vector2 = Vector2.ZERO
var punto_inicial: Vector2 = Vector2.ZERO
var en_regreso: bool = false

func _ready():
	super._ready()
	vida = 75  # Vida inicial del avión
	punto_inicial = position  # Guardar el punto inicial
	direccion = Vector2(1, 0).rotated(rotation)  # Dirección inicial basada en la orientación del avión
	direccion = direccion.normalized()

func _process(delta):
	if is_selected:
		handle_movement(delta)

func handle_movement(delta):
	# Calcula el desplazamiento en la dirección actual
	var desplazamiento = direccion * velocidad * delta
	position += desplazamiento
	distancia_recorrida += desplazamiento.length()

	# Ajusta la escala para simular la altitud
	var altura_actual = calcular_altura(distancia_recorrida)
	set_scale(Vector2(1, 1) * (1 + altura_actual / altura_maxima))

	# Verificar si alcanzó el límite o regresó al punto inicial
	if not en_regreso and distancia_recorrida >= alcance:
		print("Alcanzó el límite de alcance, regresando...")
		iniciar_regreso()
	elif en_regreso and position.distance_to(punto_inicial) <= velocidad * delta:
		print("Regresó al punto inicial.")
		finalizar_vuelo()

func calcular_altura(distancia) -> float:
	# Calcula la altitud progresiva para la ida y el regreso
	var distancia_total = alcance * 2.0  # Ida y vuelta
	var distancia_normalizada = distancia / distancia_total

	# Subida en la primera mitad y descenso en la segunda mitad
	if distancia_normalizada <= 0.5:
		return lerp(0.0, altura_maxima, distancia_normalizada * 2.0)
	else:
		return lerp(altura_maxima, 0.0, (distancia_normalizada - 0.5) * 2.0)

func iniciar_regreso():
	en_regreso = true
	direccion = -direccion  # Invierte la dirección para el regreso
	rotar_avion()
	# Crear un SceneTreeTween
	
func rotar_avion():
	var tween = create_tween()
	
	# Configurar el tipo de transición y suavizado
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Animar la rotación del avión
	tween.tween_property(self, "rotation", rotation + PI, 0.9)  # Gira 180° en 0.5 segundos

func finalizar_vuelo():
	en_regreso = false
	rotar_avion()
	distancia_recorrida = 0.0  # Reinicia la distancia recorrida
	position = punto_inicial  # Asegura que el avión vuelva exactamente al punto inicial
	direccion = Vector2(1, 0).rotated(rotation)  # Restablece la dirección inicial
	deselect_tank()
	print("Vuelo finalizado.")
