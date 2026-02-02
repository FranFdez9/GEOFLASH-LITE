extends Area2D

@export var siguiente_escena: PackedScene     
@export var fondo: Node = null                 # ParallaxBackground
@export var suelo_scroll: Node = null    # nodo que mueve el suelo
@export var label_victoria: TextureRect = null       # Label "LEVEL COMPLETE"

var activada := false


func _ready() -> void:
	# El texto de victoria empieza oculto
	if label_victoria:
		label_victoria.visible = false


# --------- utilidad para parar movimiento de nodos ---------
func parar_nodo_movimiento(n: Node) -> void:
	if n == null:
		return
	if n.has_method("set_process"):
		n.set_process(false)
	if n.has_method("set_physics_process"):
		n.set_physics_process(false)


func _on_body_entered(body: Node2D) -> void:
	#print("Meta: ha entrado algo:", body)
	if activada:
		return

	# Solo reaccionar al jugador (grupo "jugador")
	if not body.is_in_group("jugador"):
		#print("No es el jugador, salgo.")
		return

	#print("Es el jugador, activando meta.")
	activada = true

	# 1) Apagar control del jugador
	if body.has_method("set_physics_process"):
		body.set_physics_process(false)
	if "velocity" in body:
		body.velocity = Vector2.ZERO

	# 2) Parar el fondo y el suelo infinito
	parar_nodo_movimiento(fondo)
	parar_nodo_movimiento(suelo_scroll)

	# 3) Reproducir sonido final (si hay AudioStreamPlayer2D hijo de la meta)
	var audio := get_node_or_null("AudioStreamPlayer2D")
	if audio:
		audio.play()




	# 5) Mostrar texto de victoria
	if label_victoria:
		mostrar_mensaje_victoria()

	# 6) Tween general (animación lenta y épica)
	var dur := 2.3
	var tw := create_tween()
	tw.set_parallel(true)

	# Mover el jugador hasta la meta
	tw.tween_property(body, "global_position", global_position, dur)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# Girar
	tw.tween_property(body, "rotation_degrees", body.rotation_degrees + 1080.0, dur)

	# Hacerse pequeño
	tw.tween_property(body, "scale", Vector2(0.0, 0.0), dur)

	# Zoom cámara si el jugador tiene una Camera2D hija
	var cam := body.get_node_or_null("Camera2D")
	if cam:
		tw.tween_property(cam, "zoom", cam.zoom * 0.3, dur)

	# Cuando acabe la animación → cambiar de nivel
	tw.set_parallel(false)
	tw.tween_callback(Callable(self, "cargar_siguiente_nivel"))


func mostrar_mensaje_victoria() -> void:
	#print("Mostrando mensaje de victoria...")
	if label_victoria == null:
		#print("label_victoria es null, no puedo mostrarlo.")
		return

	label_victoria.visible = true
	label_victoria.modulate.a = 0.0
	label_victoria.scale = Vector2(0.4, 0.4)

	var tw := create_tween()

	# Fade in + aumento de tamaño
	tw.tween_property(label_victoria, "modulate:a", 1.0, 0.7)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tw.parallel().tween_property(label_victoria, "scale", Vector2(1.1, 1.1), 0.7)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Pequeño rebote final
	tw.tween_property(label_victoria, "scale", Vector2(0.5, 0.5), 0.25)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func cargar_siguiente_nivel() -> void:
	if siguiente_escena:
		get_tree().change_scene_to_packed(siguiente_escena)
	else:
		get_tree().reload_current_scene()
