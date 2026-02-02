extends StaticBody2D

@onready var cubo = get_node("../BloqueJugador")

func _process(delta: float) -> void:
	if cubo == null:
		return  # Jugador no cargado todavía

	# El fondo sigue al jugador
	position.x = cubo.position.x

	# Mover textura del suelo simulando scroll
	$Sprite2D.region_rect.position.x += (cubo.velocidad_horizontal / 60.0) * delta
