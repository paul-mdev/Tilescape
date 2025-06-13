extends Area2D
 
@export var item : Item:
	set(value):
		item = value
		#item.node = self
		$Sprite2D.texture = value.icon
 
var opened : bool = false:
	set(value):
		opened = value
		$Label.visible = value
		
		if value: $Sprite2D.texture.region.position.x += 16
		else: $Sprite2D.texture.region.position.x -= 16
		
var enabled : bool = false:
	set(value):
		enabled = value
		$Label.visible = value
			
func _ready():
	enabled = false
	item.parent = self
	name = item.name
 
func _input(event):
	if event is InputEventKey and event.is_pressed() and enabled:
		if event.keycode == KEY_E:
			#item.node = self
			if item:
				print("opened : ", opened)
				if opened: item.de_activate()
				else: item.activate()
				opened = !opened
				
func _on_body_entered(body):
	if body is Player and !enabled:
		print(self, "enter")
		enabled = true
	
func _on_body_exited(body):
	if body is Player and enabled:
		print(self, "leave")
		enabled = false
		if item and opened:
			item.de_activate()
		if opened: opened = false
