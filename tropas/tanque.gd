extends CharacterBody2D

var is_selected = false
var speed = 100
var vida : int = 100  # Vida inicial del tanque
@export var velocidad_giro: float = 100.0  # Grados por segundo

# Variables de la bomba para este tanque
var velocidad_bomba = 200.0
var alcance_bomba = 400.0
var poder_destruccion_bomba = 75
var radio_destruccion_bomba = 50.0

func _ready():
	add_to_group("tanques")  # Agregar el tanque a un grupo
	$Area2D.connect("input_event", Callable(self, "_on_Area2D_input_event"))
	$Area2D.input_pickable = true  # Habilita la detección de clics en el área

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		# Selecciona el tanque si no está seleccionado
		if not is_selected:
			is_selected = true
			print("Tanque seleccionado!")

func deselect_tank():
	is_selected = false
	print("Tanque deseleccionado!")

func _process(delta):
	if is_selected:
		var direction = Vector2.ZERO
		if Input.is_action_pressed("ui_up"):
			direction.y -= 1
		if Input.is_action_pressed("ui_down"):
			direction.y += 1
		if Input.is_action_pressed("ui_left"):
			direction.x -= 1
		if Input.is_action_pressed("ui_right"):
			direction.x += 1

		# Normaliza la dirección para que la velocidad sea constante en todas direcciones
		direction = direction.normalized() * speed
		
		# Establece la velocidad del tanque
		velocity = direction

		# Mueve el tanque
		move_and_slide()
		 
		if Input.is_action_just_pressed("lanzar_bomba"):
			lanzar_bomba()
	
		 # Detecta si se presiona la tecla G
		if Input.is_action_just_pressed("g"):
			# Realiza un giro de 90 grados
			rotation_degrees += 90

func recibir_dano(cantidad: int):
	vida -= cantidad
	if vida <= 0:
		morir()

func morir():
	queue_free()  # Destruye el tanque o realiza la lógica que desees

func lanzar_bomba():
	var bomba = preload("res://artilleria/bala_tanque.tscn").instantiate()

	# Posicionar la bomba ligeramente frente al tanque
	bomba.position = position + Vector2(150, 0).rotated(rotation)  # Aseguramos que la bomba salga adelante según la rotación del tanque

	# Configura las propiedades de la bomba antes de añadirla a la escena
	bomba.velocidad = velocidad_bomba
	bomba.alcance = alcance_bomba
	bomba.poder_destruccion = poder_destruccion_bomba
	bomba.radio_destruccion = radio_destruccion_bomba

	# Añadir la bomba a la escena principal, no al tanque
	get_tree().current_scene.add_child(bomba)  # Añadimos la bomba a la escena principal

	# Calculamos la dirección en que se debe mover la bomba
	var dir = Vector2(1, 0).rotated(rotation)  # Usamos la rotación del tanque para la dirección
	bomba.lanzar_bomba(dir)
