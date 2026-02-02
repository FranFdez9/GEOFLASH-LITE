extends ParallaxBackground

@export var velocidad_fondo: float = 80.0
@export var cubo: CharacterBody2D   # referencia al jugador

func _process(delta: float) -> void:
	if cubo != null and not cubo.esta_muerto:
		scroll_base_offset.x += velocidad_fondo * delta
