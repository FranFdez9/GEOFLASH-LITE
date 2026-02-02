extends Control

# ---------------------------
# Botón JUGAR
# ---------------------------
func _on_jugar_pressed() -> void:
	$AnimationPlayer.play("Comienzo")
	$SonidoComienzo.play()
	$menu.stop()
	await $AnimationPlayer.animation_finished
	Jugar()

func Jugar() -> void:
	get_tree().change_scene_to_file("res://Escenas/Prueba.tscn")


# ---------------------------
# Botón SALIR
# ---------------------------
func _on_salir_pressed() -> void: 
	$SonidoComienzo.play()
	$AnimationPlayer.play("Salida")
	await get_tree().create_timer(0.6).timeout
	salida()

func salida() -> void:
	get_tree().quit()


# ---------------------------
# Botón INVENTARIO
# ---------------------------
func _on_inventario_pressed() -> void:
	$SonidoComienzo.play()
	$AnimationPlayer.play("Invent")
	await get_tree().create_timer(0.6).timeout
	
	entrarInventario()

func entrarInventario() -> void:
	#get_tree().change_scene_to_file("res://icon.svg") Seria para hacer un inventario para cambiar las skines
	pass


# ---------------------------
# Botón AJUSTES
# ---------------------------
func _on_ajustes_pressed() -> void:
	$SonidoComienzo.play()
	$AnimationPlayer.play("Confi2")
	await get_tree().create_timer(0.6).timeout
	ajustes()
	
func ajustes() -> void:
	get_tree().change_scene_to_file("res://Objetos/opcionesPantalla.tscn") 
