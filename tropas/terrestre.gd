extends CharacterBody2D

var is_selected = false
var speed = 100
var vida: int = 100  # Vida inicial del tanque
@export var velocidad_giro: float = 100.0  # Grados por segundo

# Variables de la bomba
var velocidad_bomba = 200.0
@export var alcance_bomba: float = 900.0  # Limite de alcance
var potencia_disparo: float = 50.0  # Potencia inicial del disparo
var poder_destruccion_bomba = 75
var radio_destruccion_bomba = 50.0

@export var velocidad_inicial_potencia: float = 200.0  # Potencia inicial
@export var incremento_potencia: float = 500.0  # Velocidad a la que aumenta la potencia
var cargando_potencia = false  # Si está cargando la potencia

func _ready():
	add_to_group("tanques")  # Agregar el tanque a un grupo
	$Area2D.connect("input_event", Callable(self, "_on_Area2D_input_event"))
	$Area2D.input_pickable = true  # Habilita la detección de clics en el área

	var barra_canvas = $BarraPotencia
	var barra=barra_canvas.get_node("ProgressBar")
	if barra:
		barra.visible = false  # Oculta la barra al inicio

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if not is_selected:
			is_selected = true
			print("Tanque seleccionado!")
			var camera = get_tree().current_scene.get_node_or_null("Camera2D")
			if camera:
				camera.set_selected_tank(self)

func deselect_tank():
	is_selected = false
	print("Tanque deseleccionado!")

func _process(delta):
	if is_selected:
		handle_movement(delta)
		if cargando_potencia:
			potencia_disparo = min(potencia_disparo + incremento_potencia * delta, alcance_bomba)
			update_potencia_barra(potencia_disparo / alcance_bomba)  # Actualiza continuamente la barra

		if Input.is_action_just_pressed("lanzar_bomba"):
			iniciar_carga_potencia()

		if Input.is_action_just_released("lanzar_bomba"):
			lanzar_bomba()

func handle_movement(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1

	direction = direction.normalized() * speed
	velocity = direction
	move_and_slide()

	if Input.is_action_pressed("g"):
		rotation_degrees += velocidad_giro * delta
	if Input.is_action_pressed("f"):
		rotation_degrees -= velocidad_giro * delta

func iniciar_carga_potencia():
	cargando_potencia = true
	potencia_disparo = velocidad_inicial_potencia
	var barra_canvas = $BarraPotencia
	var barra = barra_canvas.get_node("ProgressBar")
	if barra:
		barra.visible = true
		barra.value = potencia_disparo / alcance_bomba  # Inicializa con el valor inicial

func update_potencia_barra(value):
	var barra_canvas = $BarraPotencia
	var barra = barra_canvas.get_node("ProgressBar")
	if barra:
		barra.value = value


func lanzar_bomba():
	cargando_potencia = false
	var bomba = preload("res://artilleria/bomba.tscn").instantiate()
	get_tree().current_scene.add_child(bomba)
	
	bomba.position = position + Vector2(10, 0).rotated(rotation)
	bomba.rotation = rotation  # Aplica la misma rotación del tanque a la bomba
	bomba.velocidad = velocidad_bomba
	bomba.poder_destruccion = poder_destruccion_bomba
	bomba.radio_destruccion = radio_destruccion_bomba
	bomba.alcance = alcance_bomba

	bomba.lanzar_bomba(Vector2(1, 0).rotated(rotation), potencia_disparo)

	var barra_canvas = $BarraPotencia
	var barra = barra_canvas.get_node("ProgressBar")
	if barra:
		barra.visible = false
	
	deselect_tank()
	
	var camera = get_tree().current_scene.get_node_or_null("Camera2D")
	if camera:
		camera.follow_bomb(bomba)
		
	bomba.connect("explosion", Callable(self, "_on_bomb_exploded"))
 

func _on_bomb_exploded():
	var camera = get_tree().current_scene.get_node_or_null("Camera2D")
	if camera:
		camera.stop_following_bomb()

func recibir_dano(cantidad: int):
	vida -= cantidad
	if vida <= 0:
		morir()

func morir():
	queue_free()  # Destruye el tanque o realiza la lógica que desees
