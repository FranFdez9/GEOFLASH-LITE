extends Area2D

@export var tipo: int
@onready var imgOver : Sprite2D = $over
@onready var imgBack : Sprite2D = $back
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match tipo:
		0: #Corresponde con el cubo normal.
			imgOver.modulate = Color("000000")
			imgBack.modulate = Color("000000")
		1: #Corresponde con el UFO
			imgOver.modulate = Color("61ba53")
			imgBack.modulate = Color("61ba53")
		2: #Correspondinete con la nave
			imgBack.modulate = Color("ff0f00")
			imgOver.modulate = Color("ff0f00")
		3: 	#Corresponde con la flecha.
			imgBack.modulate = Color("00ea4f")
			imgOver.modulate = Color("00ea4f")
		4: #Corresponde con el apartado ruedaPincho
			imgBack.modulate = Color("dc62b3")
			imgOver.modulate = Color("dc62b3")
		
	pass # Replace with function body.
