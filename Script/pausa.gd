extends CanvasLayer

@export var nombre_bus_musica: String = "Musica"  # nombre del bus de audio

@onready var panel          := $TextureRect
@onready var btn_continuar  := $TextureRect/BtnContinuar
@onready var btn_reiniciar  := $TextureRect/BtnReiniciar
@onready var btn_volver     := $TextureRect/BtnVolver
@onready var slider_volumen := $TextureRect/HSlider

var bus_index: int = 0


func _ready() -> void:
	
	

	# Ocultar menú al inicio
	panel.visible = false

	# Buscar el bus "Musica"
	bus_index = AudioServer.get_bus_index(nombre_bus_musica)

	# Sincronizar slider con el volumen actual del bus
	var db := AudioServer.get_bus_volume_db(bus_index)

	slider_volumen.value = db_to_linear(db)


# ------------ TECLA ESC / OPCIONES ------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Opciones"):
		var nuevo_pausa := not get_tree().paused
		get_tree().paused = nuevo_pausa
		panel.visible = nuevo_pausa
		# Consumimos el evento para que no lo use nadie más
	


# ---------------- BOTONES ----------------

func _on_btn_continuar_pressed() -> void:
	get_tree().paused = false
	panel.visible = false


func _on_btn_reiniciar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_btn_volver_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Objetos/menu.tscn")  # cambia la ruta si tu menú se llama distinto


# ------------- SLIDER VOLUMEN ------------

func _on_h_slider_value_changed(value: float) -> void:
	# value entre 0.0 y 1.0
	if value == 0.0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		var db := linear_to_db(value)
		AudioServer.set_bus_volume_db(bus_index, db)
