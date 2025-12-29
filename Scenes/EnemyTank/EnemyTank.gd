extends Node2D


@export var ChaseDistance: int = 5


@onready var MoveTimer: Timer = $MoveTimer
@onready var IdleTimer: Timer = $IdleTimer


var CurrentState: GameManager.EnemyStates = GameManager.EnemyStates.IDLE


# Movement variables
var GameMapMatrix: Array[Array] = [
		['0', '*', '0', 's'],
		['*', '*', '*', '*'],
		['0', '*', '0', '*'],
		['*', 'd', '*', '*']
	]


# Movement variables
var MoveDirection: Vector2
var CanMove


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MoveDirection = Vector2.UP
	CanMove = true
	print(shortest_path())


func shortest_path() -> int:
	var n = GameMapMatrix.size()
	var m = GameMapMatrix[0].size()

	# Direction vectors for moving: up, down, left, right
	var dRow: Array = [-1, 1, 0, 0];
	var dCol: Array = [0, 0, -1, 1];

	# Visited matrix to keep track of explored cells
	var visited: Array[Array]
	for i in n:
		var newRow: Array = []
		for j in m:
			newRow.append(false)
		visited.append(newRow)
	
	# Queue to perform BFS: stores {row, col, distance}
	var queue: Array[Array]
	
	# Find the source 's' in the matrix 
	# and start BFS from it
	for i in n:
		for j in m:
			if GameMapMatrix[i][j] == 's':
				queue.append([i ,j, 0])
				visited[i][j] = true
				break;
	
	# Standard BFS loop
	while queue.size() > 0:
		var current: Array = queue.pop_front();
		
		var row: int = current[0]
		var col: int = current[1]
		var dist: int = current[2]
		
		 # If destination 'd' is reached, return the distance
		if GameMapMatrix[row][col] == 'd':
			return dist
		
		# Explore all four adjacent directions
		for i in 4:
			var newRow: int  = row + dRow[i]
			var newCol: int = col + dCol[i]
			
			if is_valid(newRow, newCol, n, m, GameMapMatrix, visited):
				visited[newRow][newCol] = true
				queue.append([newRow, newCol , dist + 1])
		
	# If no path to destination is found, return -1
	return -1


func is_valid(row: int, col: int, n: int, m: int, mat: Array[Array], visited: Array[Array]) -> bool:
	return (row >= 0 and row < n and 
			col >= 0 and col < m and 
			mat[row][col] != '0' and 
			visited[row][col] == false);


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
	
	if CurrentState == GameManager.EnemyStates.IDLE:
		ExecuteIdle()
	elif CurrentState == GameManager.EnemyStates.PATROL:
		ExecutePatrol()
	elif CurrentState == GameManager.EnemyStates.CHASE:
		ExecuteChase()


func ExecuteIdle() -> void:
	pass


func ExecutePatrol() -> void:
	pass


func ExecuteChase() -> void:
	pass


func _on_idle_timer_timeout() -> void:
	pass # Replace with function body.
