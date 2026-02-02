extends CharacterBody2D

@export var longitud_trail := 20
@onready var wave_trail: Line2D = $WaveTrail
var puntos_trail: Array[Vector2] = []

var velocidad_horizontal = 35500
var impulso_salto = -1000
var gravedad = 4100
var en_orbe = false
var potencia_orbe = 0
var velocidad_rotacion = 400

var forma_es_ufo = false
var forma_es_cubo = false
var forma_es_nave = false
var forma_es_flecha = false  
var forma_es_rueda = false   
var esta_muerto = false

# FLECHA: empieza hacia abajo
var direccion_flecha := 1.0  # -1 = arriba, 1 = abajo

# RUEDA: gravedad propia
var gravedad_rueda := 4100.0
var signo_gravedad_rueda := 1.0  # 1 = hacia abajo, -1 = hacia arriba

var orbe_actual: Area2D = null


func _ready() -> void:

	cambiar_a_cubo()

	for nodo in get_tree().get_nodes_in_group("pad"):
		if nodo.has_signal("pad_activado"):
			nodo.connect("pad_activado", Callable(self, "_on_pad_activado"))

func _physics_process(delta: float) -> void:
	if esta_muerto:
		return

	velocity.x = velocidad_horizontal * delta

	# --- NAVE ---
	if forma_es_nave:
		_fisica_nave(delta)
		$NAVE/GPUParticles2D.emitting = Input.is_action_pressed("salto")
		move_and_slide()
		return

	# --- FLECHA / WAVE ---
	if forma_es_flecha:
		_fisica_flecha(delta)
		move_and_slide()
		actualizar_rastro_flecha()

		if get_slide_collision_count() > 0:
			muerte()
		return

	# --- RUEDA / BALL ---
	if forma_es_rueda:
		_fisica_rueda(delta)
		move_and_slide()
		return

	# --- RESTO (CUBO + UFO) ---
	if not is_on_floor():
		velocity.y += gravedad * delta
		$Sprite2D.rotation_degrees += 380 * delta
	else:
		var modulo = int($Sprite2D.rotation_degrees) % 90
		if modulo > 45:
			$Sprite2D.rotation_degrees += (90 - modulo)
		else:
			$Sprite2D.rotation_degrees -= modulo

	if Input.is_action_pressed("salto"):
		if forma_es_ufo or is_on_floor():
			velocity.y = impulso_salto

	if forma_es_ufo:
		$UFO/GPUParticles2D.emitting = Input.is_action_pressed("salto")

	if en_orbe and Input.is_action_just_pressed("salto"):
		velocity.y = -potencia_orbe

		if orbe_actual != null and orbe_actual.has_node("particles"):
			var p := orbe_actual.get_node("particles") as GPUParticles2D
			p.restart()
			p.emitting = true

	move_and_slide()


# --- FÍSICA NAVE ---
func _fisica_nave(delta: float) -> void:
	var limite_velocidad := 1865.0
	var fuerza_vertical := -45.0

	if not Input.is_action_pressed("salto"):
		fuerza_vertical = -fuerza_vertical

	velocity.y = clampf(velocity.y + fuerza_vertical, -limite_velocidad, limite_velocidad)
	var proporcion_rotacion := velocity.y / limite_velocidad
	$NAVE.rotation_degrees = proporcion_rotacion * 60.0


# --- FÍSICA FLECHA / WAVE ---
func _fisica_flecha(delta: float) -> void:
	var velocidad_wave := 650.0  
	var fuerza_curva := 10.0    

	# Cambio de dirección con clic
	if Input.is_action_just_pressed("salto"):
		direccion_flecha *= -1.0

	# Movimiento vertical constante
	velocity.y = velocidad_wave * direccion_flecha


	var objetivo_angulo := 45.0 * direccion_flecha
	$WAVE.rotation_degrees = lerp($WAVE.rotation_degrees, objetivo_angulo, delta * fuerza_curva)


# --- FÍSICA RUEDA / BALL ---
func _fisica_rueda(delta: float) -> void:
	# Gravedad propia
	velocity.y += gravedad_rueda * signo_gravedad_rueda * delta

	# SOLO PUEDE INVERTIR GRAVEDAD SI ESTÁ EN SUELO O TECHO
	if (is_on_floor() or is_on_ceiling()) and Input.is_action_just_pressed("salto"):
		signo_gravedad_rueda *= -1.0
		# Impulso hacia el nuevo "suelo"
		velocity.y = -signo_gravedad_rueda * 900.0

	# Rotación de la rueda en función de la velocidad horizontal
	var rueda := $RUEDA
	var factor_rotacion := 0.03
	rueda.rotation_degrees += (velocidad_horizontal * delta * factor_rotacion) * signo_gravedad_rueda


# --- RASTRO FLECHA ---
func actualizar_rastro_flecha() -> void:
	if not forma_es_flecha or esta_muerto:
		wave_trail.clear_points()
		puntos_trail.clear()
		return

	var punto_global := global_position
	puntos_trail.push_front(punto_global)

	if puntos_trail.size() > longitud_trail:
		puntos_trail.pop_back()

	wave_trail.clear_points()
	for p in puntos_trail:
		wave_trail.add_point(p - wave_trail.global_position)


func muerte():
	if esta_muerto:
		return

	esta_muerto = true


	# ❄️ Parar al jugador
	set_physics_process(false)
	velocidad_horizontal = 0
	velocity = Vector2.ZERO

	# 👁️ Ocultar sprites
	$Sprite2D.visible = false
	$UFO.visible = false
	$NAVE.visible = false
	$WAVE.visible = false
	$RUEDA.visible = false

	# 🧹 Limpiar estelas
	wave_trail.clear_points()
	puntos_trail.clear()

	# --- Crear partículas de muerte dinámicamente ---
	  # --- Crear partículas de muerte dinámicamente ---
	if $die_particles:
		var fx = $die_particles.duplicate()  # Instanciamos en memoria
		fx.one_shot = true
		fx.global_position = global_position
		get_parent().add_child(fx)
		fx.restart()  # Comienza a emitir inmediatamente

		# Liberar memoria usando un Timer basado en la duración de las partículas
		var tiempo_vida = fx.lifetime
		var t = Timer.new()
		t.one_shot = true
		t.wait_time = tiempo_vida
		t.connect("timeout", Callable(fx, "queue_free"))
		fx.add_child(t)
		t.start()
	# 🔊 Sonido de muerte
	$AudioStreamPlayer2D.play()

	# ⏱️ Reiniciar nivel con timer
	$Timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()


func _on_exterior_area_entered(area: Area2D) -> void:
	if area.is_in_group("Lanzador"):
		en_orbe = true
		potencia_orbe = area.fuerza
		orbe_actual = area

	if area.is_in_group("portal"):
		match area.tipo:
			0:
				cambiar_a_cubo()
			1:
				cambiar_a_ufo()
			2:
				cambiar_a_nave()
			3:
				cambiar_a_flecha()
			4:
				cambiar_a_rueda()


func _on_exterior_area_exited(area: Area2D) -> void:
	if area.is_in_group("Lanzador"):
		en_orbe = false
		potencia_orbe  = 0
		if orbe_actual == area:
			orbe_actual = null
	pass


# ----------------------
# CAMBIO DE FORMAS
# ----------------------
func cambiar_a_cubo():
	forma_es_cubo = true
	forma_es_ufo = false
	forma_es_nave = false
	forma_es_flecha = false
	forma_es_rueda = false

	$Sprite2D.visible = true
	$UFO.visible = false
	$NAVE.visible = false
	$WAVE.visible = false
	$RUEDA.visible = false

	impulso_salto = -1000
	$Sprite2D.rotation_degrees = -90
	$NAVE.rotation_degrees = 0
	$WAVE.rotation_degrees = 0

	$UFO/GPUParticles2D.emitting = false
	$NAVE/GPUParticles2D.emitting = false

	wave_trail.clear_points()
	puntos_trail.clear()


func cambiar_a_ufo():
	forma_es_cubo = false
	forma_es_ufo = true
	forma_es_nave = false
	forma_es_flecha = false
	forma_es_rueda = false

	$Sprite2D.visible = false
	$UFO.visible = true
	$NAVE.visible = false
	$WAVE.visible = false
	$RUEDA.visible = false

	impulso_salto = -450
	$Sprite2D.rotation_degrees = 0
	$NAVE.rotation_degrees = 0
	$WAVE.rotation_degrees = 0

	($UFO/GPUParticles2D.process_material as ParticleProcessMaterial).color = Color(0, 0, 0)
	$UFO/GPUParticles2D.emitting = false

	wave_trail.clear_points()
	puntos_trail.clear()


func cambiar_a_nave():
	forma_es_cubo = false
	forma_es_ufo = false
	forma_es_nave = true
	forma_es_flecha = false
	forma_es_rueda = false

	$Sprite2D.visible = false
	$UFO.visible = false
	$NAVE.visible = true
	$WAVE.visible = false
	$RUEDA.visible = false

	impulso_salto = -500
	velocity.y = 0
	$Sprite2D.rotation_degrees = 0
	$NAVE.rotation_degrees = 0
	$WAVE.rotation_degrees = 0

	($NAVE/GPUParticles2D.process_material as ParticleProcessMaterial).color = Color(1, 1, 0)
	$NAVE/GPUParticles2D.emitting = false

	wave_trail.clear_points()
	puntos_trail.clear()


func cambiar_a_flecha():
	forma_es_cubo = false
	forma_es_ufo = false
	forma_es_nave = false
	forma_es_flecha = true
	forma_es_rueda = false

	$Sprite2D.visible = false
	$UFO.visible = false
	$NAVE.visible = false
	$WAVE.visible = true
	$RUEDA.visible = false

	velocity.y = 0
	direccion_flecha = 1.0
	$WAVE.rotation_degrees = 45.0

	puntos_trail.clear()
	wave_trail.clear_points()


func cambiar_a_rueda():
	forma_es_cubo = false
	forma_es_ufo = false
	forma_es_nave = false
	forma_es_flecha = false
	forma_es_rueda = true

	$Sprite2D.visible = false
	$UFO.visible = false
	$NAVE.visible = false
	$WAVE.visible = false
	$RUEDA.visible = true

	signo_gravedad_rueda = 1.0
	velocity.y = 0
	$RUEDA.rotation_degrees = 0

	wave_trail.clear_points()
	puntos_trail.clear()

func _on_pad_activado(fuerza: float, invertir: bool) -> void:
	print("Señal recibida en jugador!")
	if invertir:
		velocity.y = fuerza
	else:
		velocity.y = -fuerza
