extends Area2D

@export var velocidad: float = 200.0
@export var alcance: float = 300.0
@export var poder_destruccion: int = 50
@export var radio_destruccion: float = 50.0
@export var desfase_posicion: float = 10.0  # Ajuste para que la bomba salga un poco adelante

# Variables internas
var distancia_recorrida: float = 0.0
var direccion: Vector2 = Vector2.ZERO
var tanque_padre: Node = null  # Referencia al nodo del tanque que disparó la bomba

func _ready():
	# Asegurarnos de que la bomba se inicie correctamente desde el tanque
	#tanque_padre = get_parent()  # Obtener el nodo del tanque que disparó la bomba

	# Conectamos la señal body_entered a la función correspondiente
	connect("body_entered", Callable(self, "_on_body_entered"))

# Método para lanzar la bomba en una dirección específica
func lanzar_bomba(dir: Vector2):
	direccion = dir.normalized()  # Normaliza la dirección del disparo
	distancia_recorrida = 0.0     # Reinicia la distancia recorrida
	#position = tanque_padre.position + direccion * desfase_posicion  # Posiciona la bomba ligeramente adelante

# Método para mover la bomba y verificar si alcanza el alcance máximo
func _process(delta):
	var desplazamiento = direccion * velocidad * delta
	position += desplazamiento  # Actualiza la posición de la bomba en cada frame
	distancia_recorrida += desplazamiento.length()

	# Si la bomba alcanza el alcance, explota
	if distancia_recorrida >= alcance:
		queue_free()  # Destruye la bomba cuando alcanza el alcance

# Función llamada cuando un cuerpo entra en el área de la bomba
func _on_body_entered(body):
	print("La bomba ha tocado a: ", body.name)  # Depuración para ver qué cuerpo tocó la bomba
	explotar(body)

# Método para manejar la explosión de la bomba
func explotar(body: Node):
	# Asegurarse de que no se dañe al tanque que disparó la bomba
	if body != tanque_padre and (body.is_in_group("tanques") or body.is_in_group("enemigos")):
		body.recibir_dano(poder_destruccion)  # Llama a la función recibir_dano() del tanque o enemigo

	queue_free()  # Destruye la bomba después de la explosión
