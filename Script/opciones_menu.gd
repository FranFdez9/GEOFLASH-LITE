extends CanvasLayer   

@export var nombre_bus_musica: String = "MenuMusica"   

@onready var boton_volver: Button = $TextureRect/BtnVolver
@onready var slider_volumen: HSlider = $TextureRect/HSlider

var bus_index: int = 0


func _ready() -> void:
	
	get_tree().paused = false

	# --- AUDIO ---
	bus_index = AudioServer.get_bus_index(nombre_bus_musica)
	if bus_index == -1:
		push_warning("No existe un bus de audio llamado: %s" % nombre_bus_musica)
		return

	# Configuramos el slider para 0–1
	slider_volumen.min_value = 0.0
	slider_volumen.max_value = 1.0

	# Lo ponemos al volumen actual del bus
	var db := AudioServer.get_bus_volume_db(bus_index)
	var lin := db_to_linear(db)          # 0.0 .. 1.0
	slider_volumen.value = lin


# ---------------- BOTÓN VOLVER ----------------
func _on_btn_volver_pressed() -> void:
	# Volvemos al menú principal
	get_tree().change_scene_to_file("res://Objetos/menu.tscn") 


# ------------- SLIDER VOLUMEN -----------------
func _on_h_slider_value_changed(value: float) -> void:
	if bus_index == -1:
		return

	# value está entre 0.0 y 1.0
	if value <= 0.001:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		var db := linear_to_db(value)
		AudioServer.set_bus_volume_db(bus_index, db)
