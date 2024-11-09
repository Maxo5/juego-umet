extends Camera2D

var speed = 100  # Velocidad de movimiento de la cámara
var selected_tank = null  # Variable para almacenar el tanque seleccionado

func _process(delta):
	# Solo mover la cámara si no hay un tanque seleccionado
	if selected_tank == null:
		var direction = Vector2.ZERO

		# Movimiento de la cámara
		if Input.is_action_pressed("ui_up"):
			direction.y -= 1
		if Input.is_action_pressed("ui_down"):
			direction.y += 1
		if Input.is_action_pressed("ui_left"):
			direction.x -= 1
		if Input.is_action_pressed("ui_right"):
			direction.x += 1

		# Mover la cámara
		position += direction.normalized() * speed * delta
	else:
		# Si hay un tanque seleccionado, sigue su posición
		position = selected_tank.position

# Método para establecer el tanque seleccionado
func set_selected_tank(tank):
	selected_tank = tank
