extends Node2D  # Cambia esto al tipo de nodo que sea apropiado para tu terreno

func _input(event):
	# Verificamos si el evento es un clic de ratón
	if event is InputEventMouseButton and event.pressed:
		# Solo deseleccionamos los tanques cuando se hace clic en el terreno
		var tanks = get_tree().get_nodes_in_group("tanques")  # Asegúrate de que tus tanques estén en un grupo
		for tank in tanks:
			tank.deselect_tank()  # Deselecciona el tanque
			
		# Notifica a la cámara que debe dejar de seguir al tanque
		var camera = get_tree().current_scene.get_node("Camera2D")
		camera.stop_following_tank()  # Detiene el seguimiento del tanque
