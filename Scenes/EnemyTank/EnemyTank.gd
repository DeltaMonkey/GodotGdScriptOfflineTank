extends Node2D


@export var ChaseDistance: int = 5


@onready var MoveTimer: Timer = $MoveTimer


var CurrentState: GameManager.EnemyStates = GameManager.EnemyStates.IDLE


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


func move_tank() -> void:
	if CanMove:
		CanMove = false
		MoveTimer.start()


func UpdatePerceptions() -> void:
	var instanceId: String = str(get_instance_id())
	var distanceToPlayer = GameManager.PlayerTankPositionData.distance_to(GameManager.EnemyTankPositionData[instanceId])
	if distanceToPlayer <= ChaseDistance:
		CurrentState = GameManager.EnemyStates.CHASE
	elif distanceToPlayer > ChaseDistance and CurrentState == GameManager.EnemyStates.CHASE: # Çok uzaklaştıysa takibi bırak
			CurrentState = GameManager.EnemyStates.PATROL

func _on_move_timer_timeout() -> void:
	UpdatePerceptions()
