extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Muertes"):
		$"..".muerte() #llamo a la funcion del nodo padre juado
		self.queue_free() #para sumprimir los controles durante el timer
	
