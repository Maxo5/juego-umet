extends Node2D
@export var base_scale: float = 1.0  # Tamaño base de la explosión
@export var max_scale: float = 3.0  # Escala máxima posible
@export var duracion: float = 0.5  # Duración de la animación en segundos
var poder: float = 0.0  # Variable para almacenar el poder de la bomba


func iniciar_explosion(poder_iniciado):
	# Ajusta la escala del sprite basado en el poder de la bomba
	var sprite = $Sprite2D
	poder=poder_iniciado
	
	#if sprite:# Reduzco el impacto del poder usando una raíz cuadrada
		#var escala = base_scale + (max_scale - base_scale) * (poder / 100.0)
	sprite.scale = Vector2(0.1, 0.1)
		#print("Escala calculada: ", escala)

	# Reproducir animación
	var anim_player = $AnimationPlayer
	if anim_player:
		anim_player.play("explosion_bomba")

	


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("Animación terminada: ", anim_name)
	
	if anim_name == "explosion_bomba":
		# Oculta el Sprite para que desaparezca la imagen
		$Sprite2D.visible = false

		# Obtén las partículas
		var particles = $particulas
		if particles:
			# Ajusta la escala de las partículas según el poder
			var escala_particulas = base_scale + (max_scale - base_scale) * (poder / 100.0)
			particles.scale = Vector2(escala_particulas, escala_particulas)  # Cambia la escala de las partículas
			
			# Verifica si el material de partículas está bien configurado para simular fuego
			#var material = particles.material
			#if particles.material is ShaderMaterial:
				
				#var shader_material = particles.material as ShaderMaterial
				#shader_material.set("shader_param/time", poder / 100.0)  # Modifica el parámetro 'time'

				
			#particles.emitting = true  # Asegúrate de que las partículas sigan emitiendo
		
		# Espera 2 segundos antes de liberar el nodo
		var timer = Timer.new()
		timer.wait_time = 2.0  # Tiempo de espera de 2 segundos
		add_child(timer)  # Añadir el Timer como hijo del nodo para que pueda ejecutarse
		await timer.timeout  # Espera a que termine el tiempo
		timer.queue_free()  # Elimina el Timer después de usarlo
		queue_free()  # Elimina el nodo completo
