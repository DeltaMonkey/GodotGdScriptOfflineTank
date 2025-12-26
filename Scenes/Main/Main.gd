extends Node


@export var PlayerTankScene: PackedScene
@export var BaseDoorScene: PackedScene

@onready var HUD: CanvasLayer = $HUD

var StartPos: Vector2 = Vector2(7, 7)
var BaseStartPos: Vector2 = Vector2(7, 16)

func _ready() -> void:
	new_game()


func new_game() -> void:
	GameManager.Score = 0
	HUD.get_node("ScoreLabel").text = "SCORE: " + str(GameManager.Score)
	spawn_player()
	spawn_base()


func spawn_player():
	var playerStartPosition: Vector2 = StartPos + Vector2(0, 1)
	GameManager.PlayerTankPositionData = playerStartPosition
	var playerTank = PlayerTankScene.instantiate()
	playerTank.position = (playerStartPosition * GameManager.CellSize) + Vector2(0, GameManager.CellSize)
	add_child(playerTank)
	GameManager.PlayerTank = playerTank


func spawn_base():
	GameManager.BaseDoorPositionData = BaseStartPos
	var baseDoor = BaseDoorScene.instantiate()
	baseDoor.position = (GameManager.BaseDoorPositionData * GameManager.CellSize) + Vector2(0, GameManager.CellSize)
	add_child(baseDoor)
	GameManager.BaseDoor = baseDoor


func _process(delta: float) -> void:
	pass
