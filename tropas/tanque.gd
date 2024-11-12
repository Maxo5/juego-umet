extends CharacterBody2D

var is_selected = false
var speed = 100
var vida: int = 100  # Vida inicial del tanque
@export var velocidad_giro: float = 100.0  # Grados por segundo

# Variables de la bomba para este tanque
var velocidad_bomba = 200.0
@export var alcance_bomba: float = 700.0
var potencia_disparo: float = 700.0  
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
			# Notifica a la cámara que debe seguir este tanque
			var camera = get_tree().current_scene.get_node("Camera2D")
			camera.set_selected_tank(self)

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

		# Normaliza la dirección para mantener velocidad constante
		direction = direction.normalized() * speed
		
		# Establece la velocidad del tanque
		velocity = direction

		# Mueve el tanque
		move_and_slide()
		 
		# Lanzar bomba al presionar tecla asignada
		if Input.is_action_just_pressed("lanzar_bomba"):
			lanzar_bomba()
	
		# Rotación incremental al presionar 'g'
		if Input.is_action_pressed("g"):
			rotation_degrees += velocidad_giro * delta

func recibir_dano(cantidad: int):
	vida -= cantidad
	if vida <= 0:
		morir()

func morir():
	queue_free()  # Destruye el tanque o realiza la lógica que desees

func lanzar_bomba():
	var bomba = preload("res://artilleria/bala_tanque.tscn").instantiate()
	get_tree().current_scene.add_child(bomba)
	
	bomba.position = position + Vector2(150, 0).rotated(rotation)
	bomba.velocidad = velocidad_bomba
	bomba.poder_destruccion = poder_destruccion_bomba
	bomba.radio_destruccion = radio_destruccion_bomba
	bomba.alcance = alcance_bomba
	
	var dir = Vector2(1, 0).rotated(rotation)
	bomba.lanzar_bomba(dir, potencia_disparo)
	deselect_tank()
	# Indica a la cámara que siga la bomba
	get_tree().current_scene.get_node("Camera2D").follow_bomb(bomba)
	
	# Conecta la señal de explosión para que la cámara deje de seguirla
	bomba.connect("explosion", Callable(self, "_on_bomb_exploded"))

func _on_bomb_exploded():
	get_tree().current_scene.get_node("Camera2D").stop_following_bomb()
