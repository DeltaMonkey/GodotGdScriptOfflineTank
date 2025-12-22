extends Node


@export var PlayerTankScene: PackedScene


@onready var MoveTimer: Timer = $MoveTimer
@onready var HUD: CanvasLayer = $HUD


# Game variables
var Score: int
var GameStarted: bool = false


# Grid variables
var Cells: int = 16 # each row
var CellSize: int = 32


# Player Positions
var PlayerTankPositionData: Vector2 # position for matrix
var PlayerTank: Node2D


# Movement variables
var StartPos: Vector2 = Vector2(7, 7)
var MoveDirection: Vector2
var CanMove


func _ready() -> void:
	new_game()


func new_game() -> void:
	Score = 0
	HUD.get_node("ScoreLabel").text = "SCORE: " + str(Score)
	MoveDirection = Vector2.UP
	CanMove = true
	spawn_player()


func spawn_player():
	var playerStartPosition: Vector2 = StartPos + Vector2(0, 1)
	PlayerTankPositionData = playerStartPosition
	var playerTank = PlayerTankScene.instantiate()
	playerTank.position = (playerStartPosition * CellSize) + Vector2(0, CellSize)
	add_child(playerTank)
	PlayerTank = playerTank


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
	if not GameStarted:
		start_game()


func start_game() -> void:
	GameStarted = true
	MoveTimer.start()


func _on_move_timer_timeout() -> void:
	# Allow tank movement
	CanMove = true
	# Use the player's previous position to move
	PlayerTankPositionData += MoveDirection
	if !check_out_of_bounds():
		PlayerTankPositionData -= MoveDirection
	PlayerTank.position = (PlayerTankPositionData * CellSize) + Vector2(0, CellSize) 
	(PlayerTank.get_node("TankBodySprite") as Sprite2D).global_rotation_degrees = rad_to_deg(MoveDirection.angle()) + 90

func check_out_of_bounds() -> bool:
	if PlayerTankPositionData.x < 0 or PlayerTankPositionData.x > Cells - 1 or PlayerTankPositionData.y < 1 or PlayerTankPositionData.y > Cells:
		return false
	return true
