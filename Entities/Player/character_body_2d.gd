extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -600.0

var time = 0.1

const maxBodies = 6
var bodyCnt = 0

var index: int = 0

var CorpseScene := preload("res://Entities/OldBody/OldBodyScene.tscn")
var BodiesArray : Array = [null, null, null, null]

enum Potions { POISON, REMOVE }
var currentPotion : Potions

@onready var spawn_point: Marker2D = $"../SpawnPoint"

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var sprite: Sprite2D = $CharacterSprite

@onready var selectRectPoison: ColorRect = $"UI/Rect4/SelectRectPoison"
@onready var selectRectRemove: ColorRect = $"UI/Rect5/SelectRectRemove"
@onready var potion_label: Label = $PotionLabel
@onready var timer: Timer = $Timer
@onready var TimeLabel: Label = $"UI/Label"

func _ready() -> void:
	self.add_to_group("Player")
	timer.set_wait_time(time)
	if (selectRectPoison != null):
		selectRectPoison.visible = false
	if (selectRectRemove != null):
		selectRectRemove.visible = false

func canSpawnBody() -> bool:
	
	return bodyCnt < maxBodies

func spawn_old_body(pos : Vector2, index: int):
	var old_body_instance = CorpseScene.instantiate()
	get_tree().current_scene.add_child(old_body_instance)
	old_body_instance.global_position = pos
	BodiesArray[index] = old_body_instance
	print("Cadavru adaugat în stivă la indexul: ", index)



func select_potion():
	if(Input.is_action_just_pressed("q")):
		currentPotion = Potions.POISON
		selectRectPoison.visible = true
		selectRectRemove.visible = false
		
		if (canSpawnBody() and timer.is_stopped()):
			timer.start()
			

	if(Input.is_action_just_pressed("e")):
		currentPotion = Potions.REMOVE
		selectRectPoison.visible = false
		selectRectRemove.visible = true
		
		
			
	if(currentPotion == Potions.POISON):
		potion_label.text = "POISON"
	if(currentPotion == Potions.REMOVE):
		potion_label.text = "REMOVE"

func _physics_process(delta: float) -> void:
	TimeLabel.text = str(snapped(timer.time_left, 0.1))
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	select_potion()

	if Input.is_action_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")


	if Input.is_action_just_pressed("e"):
		if bodyCnt > -1:
			var selected_corpse = BodiesArray[index]
			for corpse in BodiesArray:
				if corpse != null:
					corpse.modulate = Color.WHITE

			if selected_corpse != null:
				print("Selectat cadavrul #: ", index)
				selected_corpse.queue_free()
				print("ff")
				bodyCnt-=1
				
			if (bodyCnt > 0):
				index = (index + 1) % bodyCnt
			else:
				print("Nu există cadavre pe hartă încă.")

	if direction:
		sprite.flip_h = true if direction < 0 else false
		animation_player.play("Running")
		velocity.x = lerp(velocity.x, direction * SPEED, 0.35)
	else:
		animation_player.stop()
		velocity.x = lerp(velocity.x, 0.0, 0.23)
	move_and_slide()

func _on_timer_timeout() -> void:
	if(bodyCnt < maxBodies):
		var oldPos = global_position
		self.global_position = spawn_point.global_position
		spawn_old_body(oldPos, bodyCnt)
		bodyCnt += 1 #Creștem numărul total de cadavre existente
