extends Node2D


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
	move_tank()

func move_tank():
	if CanMove:
		# Update movement from keypress
		if Input.is_action_just_pressed("ui_down") and MoveDirection != Vector2.UP:
			select_move_to_direction(Vector2.DOWN)
		if Input.is_action_just_pressed("ui_up") and MoveDirection != Vector2.DOWN:
			select_move_to_direction(Vector2.UP)
		if Input.is_action_just_pressed("ui_left") and MoveDirection != Vector2.RIGHT:
			select_move_to_direction(Vector2.LEFT)
		if Input.is_action_just_pressed("ui_right") and MoveDirection != Vector2.LEFT:
			select_move_to_direction(Vector2.RIGHT)


func select_move_to_direction(direction: Vector2) -> void:
	MoveDirection = direction
	CanMove = false
	if not GameManager.GameStarted:
		start_game()


func start_game() -> void:
	GameManager.GameStarted = true
	MoveTimer.start()


func _on_move_timer_timeout() -> void:
	# Allow tank movement
	CanMove = true
	# Use the player's previous position to move
	GameManager.PlayerTankPositionData += MoveDirection
	if !check_out_of_bounds():
		GameManager.PlayerTankPositionData -= MoveDirection
	GameManager.PlayerTank.position = (GameManager.PlayerTankPositionData * GameManager.CellSize) + Vector2(0, GameManager.CellSize) 
	(GameManager.PlayerTank.get_node("TankBodySprite") as Sprite2D).global_rotation_degrees = rad_to_deg(MoveDirection.angle()) + 90


func check_out_of_bounds() -> bool:
	if (GameManager.PlayerTankPositionData.x < 0 
		or GameManager.PlayerTankPositionData.x > GameManager.Cells - 1 
		or GameManager.PlayerTankPositionData.y < 1 
		or GameManager.PlayerTankPositionData.y > GameManager.Cells):
		return false
	return true
