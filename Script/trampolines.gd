extends Area2D

# --- Señal para comunicar al jugador ---
signal pad_activado(fuerza: float, invertir: bool)

@export var tipoPad := 0
@onready var point : Sprite2D = $Point
@onready var particles := $particles

var fuerza := 0
var invertir := false

func _ready() -> void:
	# Cada pad tiene su propio material de partículas
	particles.process_material = particles.process_material.duplicate()
	particles.emitting = true

	"""
	0 = Amarillo  (pequeño salto extra)
	1 = Rosa      (salto grande)
	2 = Azul      (salto invertido hacia abajo)
	3 = Blanco    (mini salto)
	4 = Naranja   (salto fuerte invertido)
	"""

	match tipoPad:
		0: # Amarillo
			fuerza = 1100
			#invertir = false
			point.modulate = Color(1, 1, 0)
			particles.process_material.color = Color(1, 1, 0)

		1: # Rosa
			fuerza = 1500
			#invertir = false
			point.modulate = Color(1, 0.2, 0.6)
			particles.process_material.color = Color(1, 0.2, 0.6)

		2: # Azul invertido
			fuerza = 1250
			#invertir = true
			point.modulate = Color(0.2, 0.4, 1)
			particles.process_material.color = Color(0.2, 0.4, 1)

		3: # Blanco mini
			fuerza = 800
			#invertir = false
			point.modulate = Color(1, 1, 1)
			particles.process_material.color = Color(1, 1, 1)

		4: # Naranja invertido fuerte
			fuerza = 1200
			#invertir = false
			point.modulate = Color(1, 0.5, 0)
			particles.process_material.color = Color(1, 0.5, 0)
			
		5: # 🟣 Morado invertido hacia abajo
			fuerza = 1100
			invertir= true
			point.modulate = Color(0.8, 0, 1)
			particles.process_material.color = Color(0.8, 0, 1)

		_:
			queue_free()
			
# --- Detectar cuando el jugador entra en el pad ---


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("jugador"):
		print("Pad: jugador detectado")
		emit_signal("pad_activado", fuerza, invertir)
