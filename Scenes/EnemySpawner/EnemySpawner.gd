extends Node2D


@export var EnemyTankScene: PackedScene 
@export var SpawnerMatrixPosition: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn_enemy() -> void:
	#if GameManager.GameStarted:
	var enemyTank = EnemyTankScene.instantiate()
	var instanceId: String = str(enemyTank.get_instance_id())
	GameManager.EnemyTankPositionData[instanceId] = SpawnerMatrixPosition
	enemyTank.position = (GameManager.EnemyTankPositionData[instanceId]  * GameManager.CellSize) + Vector2(0, GameManager.CellSize)
	print(enemyTank.position)
	get_tree().root.get_node("Main").add_child(enemyTank)
	GameManager.EnemyTanks[instanceId] = enemyTank


func _on_spawn_timer_timeout() -> void:
	spawn_enemy()
