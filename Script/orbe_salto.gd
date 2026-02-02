extends Area2D

@export var tipoOrbe := 0

var fuerza := 0

@onready var sprite: Sprite2D        = $Sprite2D
@onready var particles: GPUParticles2D = $particles


func _ready() -> void:
	"""
	0 = Rosa      (salto grande)
	1 = Amarillo  (salto medio)
	2 = Azul      (salto fuerte)
	3 = Blanco    (salto pequeño)
	4 = Naranja   (salto muy fuerte)
	"""

	# Aseguramos que cada orbe tiene su propio material de partículas
	if particles.process_material != null:
		particles.process_material = particles.process_material.duplicate()

	# Las partículas solo se encenderán cuando el jugador salte sobre la orbe
	particles.emitting = false

	match tipoOrbe:
		0: # Rosa
			fuerza = 800
			sprite.modulate = Color(1.0, 0.3, 0.7)
			(particles.process_material as ParticleProcessMaterial).color = Color(1.0, 0.3, 0.7)

		1: # Amarillo
			fuerza = 1400
			sprite.modulate = Color(1.0, 1.0, 0.0)
			(particles.process_material as ParticleProcessMaterial).color = Color(1.0, 1.0, 0.0)

		2: # Azul
			fuerza = 1700
			sprite.modulate = Color(0.2, 0.5, 1.0)
			(particles.process_material as ParticleProcessMaterial).color = Color(0.2, 0.5, 1.0)

		3: # Blanco
			fuerza = 1000
			sprite.modulate = Color(1.0, 1.0, 1.0)
			(particles.process_material as ParticleProcessMaterial).color = Color(1.0, 1.0, 1.0)

		4: # Naranja
			fuerza = 2000
			sprite.modulate = Color(1.0, 0.6, 0.0)
			(particles.process_material as ParticleProcessMaterial).color = Color(1.0, 0.6, 0.0)

		_:
			queue_free()
