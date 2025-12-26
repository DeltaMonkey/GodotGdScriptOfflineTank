extends Node2D


class_name Bullet


@export var Explotion1Scene: PackedScene


@onready var MoveTimer: Timer = $MoveTimer


# Movement variables
var MoveDirection: Vector2
var CanMove


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MoveDirection = Vector2.UP
	CanMove = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_bullet()
	did_i_shoot_anyone()


func move_bullet() -> void:
	if CanMove:
		CanMove = false
		MoveTimer.start()


func _on_move_timer_timeout() -> void:
	# Allow bullet movement
	CanMove = true
	var instanceId: String = str(get_instance_id())
	if !GameManager.BulletsPositionData.has(instanceId):
		GameManager.BulletsPositionData[instanceId] = Vector2(GameManager.PlayerTankPositionData.x, GameManager.PlayerTankPositionData.y) # TODO: enemy'e gore ayarlanacak
	GameManager.BulletsPositionData[instanceId] += MoveDirection
	if !check_out_of_bounds():
		pass
		queue_free()
	
	GameManager.Bullets[instanceId].position = (GameManager.BulletsPositionData[instanceId] * GameManager.CellSize) + Vector2(0, GameManager.CellSize) 
	print(GameManager.Bullets[instanceId].position)
	(GameManager.Bullets[instanceId].get_node("BulletSprite") as Sprite2D).global_rotation_degrees = rad_to_deg(MoveDirection.angle()) + 90
 

func check_out_of_bounds() -> bool:
	var instanceId: String = str(get_instance_id())
	if (GameManager.BulletsPositionData[instanceId].x < 0 
		or GameManager.BulletsPositionData[instanceId].x > GameManager.Cells - 1 
		or GameManager.BulletsPositionData[instanceId].y < 1 
		or GameManager.BulletsPositionData[instanceId].y > GameManager.Cells):
		return false
	return true


func set_move_direction(moveDirection: Vector2):
	MoveDirection = moveDirection


func did_i_shoot_anyone() -> void:
	check_i_shoot_base()


func check_i_shoot_base() -> void:
	var instanceId: String = str(get_instance_id())
	if GameManager.BulletsPositionData[instanceId] == GameManager.BaseDoorPositionData:
		GameManager.BaseDoor.queue_free()
		create_explotion(GameManager.BaseDoorPositionData)
		GameManager.BaseDoorPositionData = Vector2.ZERO


func create_explotion(explotionPosition: Vector2):
	var explotion = Explotion1Scene.instantiate()
	explotion.position = (explotionPosition * GameManager.CellSize) + Vector2(0, GameManager.CellSize)
	get_tree().root.get_node("Main").add_child(explotion)
