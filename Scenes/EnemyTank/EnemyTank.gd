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
		['*', 'd', '0', '*']
	]


# Movement variables
var MoveDirection: Vector2
var CanMove


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MoveDirection = Vector2.UP
	CanMove = true
	shortest_path(GameMapMatrix)


func shortest_path(gameMapMatrix: Array[Array]) -> Array[BreadthFirstSearchNode]:
	var n = gameMapMatrix.size()
	var m = gameMapMatrix[0].size()

	# Direction vectors for moving: up, down, left, right
	var dRow: Array = [1, -1, 0, 0];
	var dCol: Array = [0, 0, -1, 1];

	# Visited matrix to keep track of explored cells
	var visited: Array[Array]
	for i in n:
		var newRow: Array = []
		for j in m:
			newRow.append(false)
		visited.append(newRow)
	
	# Queue to perform BFS: stores {row, col, distance}
	var rowColDistQueue: Array[BreadthFirstSearchNode]
	
	# Find the source 's' in the matrix 
	# and start BFS from it
	for i in n:
		for j in m:
			if gameMapMatrix[i][j] == 's':
				rowColDistQueue.push_back(BreadthFirstSearchNode.new().create(i, j , 0))
				visited[i][j] = true
				break;
	
	var nodesToPath: Array[BreadthFirstSearchNode]
	var pathToFollow: Array[BreadthFirstSearchNode]
	
	# Standard BFS loop
	while rowColDistQueue.size() > 0:
		var currentNode: BreadthFirstSearchNode = rowColDistQueue.pop_front();
		 # If destination 'd' is reached, return the distance
		if gameMapMatrix[currentNode.Row][currentNode.Col] == 'd':
			var pathFinalNode: BreadthFirstSearchNode = nodesToPath.pop_back()
			pathToFollow.append(pathFinalNode)
			var pathNextNode: BreadthFirstSearchNode = pathFinalNode
			while pathToFollow.size() != pathFinalNode.Distance:
				for i in nodesToPath.size():
					# row col dist
					if nodesToPath[i].Row == pathNextNode.BeforeNode.Row and nodesToPath[i].Col == pathNextNode.BeforeNode.Col and nodesToPath[i].Distance == pathNextNode.BeforeNode.Distance:
						pathNextNode = nodesToPath[i]
						pathToFollow.append(pathNextNode)
			
			for i in pathToFollow:
				print("(", i.Row, ", ", i.Col, ") | ", i.Distance, " | BeforeNode: (", i.BeforeNode.Row, ", ", i.BeforeNode.Col, ") | ", i.BeforeNode.Distance, " | ")
			
			return pathToFollow
		
		# Explore all four adjacent directions
		for i in 4:
			var newRow: int  = currentNode.Row + dRow[i]
			var newCol: int = currentNode.Col + dCol[i]
			
			if is_valid(newRow, newCol, n, m, gameMapMatrix, visited):
				visited[newRow][newCol] = true
				var parentNode: BreadthFirstSearchNode = BreadthFirstSearchNode.new().create(currentNode.Row, currentNode.Col, currentNode.Distance)
				var newCellToPath = BreadthFirstSearchNode.new().create(newRow, newCol, currentNode.Distance + 1, parentNode)
				rowColDistQueue.append(newCellToPath)
				nodesToPath.append(newCellToPath)
	
	# If no path to destination is found, return -1
	return []


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
