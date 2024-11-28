extends Camera2D

var speed = 800  # Velocidad de movimiento manual de la cámara
var selected_tank = null  # Tanque seleccionado
var target = null  # Objeto que la cámara sigue (tanque o bomba)
@export var follow_smoothness: float = 0.01  # Cuanto menor sea, más suave es el seguimiento

func _process(delta):
	if target == null:
		# Movimiento manual de la cámara si no hay objetivo
		var direction = Vector2.ZERO

		if Input.is_action_pressed("ui_up"):
			direction.y -= 1
		if Input.is_action_pressed("ui_down"):
			direction.y += 1
		if Input.is_action_pressed("ui_left"):
			direction.x -= 1
		if Input.is_action_pressed("ui_right"):
			direction.x += 1

		position += direction.normalized() * speed * delta
	else:
		# Suaviza la transición hacia el objetivo
		position = position.lerp(target.position, follow_smoothness)

func set_selected_tank(tank):
	selected_tank = tank
	target = tank  # La cámara sigue al tanque

func follow_bomb(bomb):
	target = bomb  # Cambia el objetivo de la cámara a la bomba
	bomb.connect("bomba_explotada", Callable(self, "stop_following_bomb")) # Es

func stop_following_bomb():
	target = selected_tank

# Método para dejar de seguir al tanque
func stop_following_tank():
	target = null  # La cámara deja de seguir al tanque
