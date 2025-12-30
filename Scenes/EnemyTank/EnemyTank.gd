extends Node2D


@export var ChaseDistance: int = 5


@onready var MoveTimer: Timer = $MoveTimer
@onready var IdleTimer: Timer = $IdleTimer


var CurrentState: GameManager.EnemyStates = GameManager.EnemyStates.IDLE


# Movement variables
var CanMove

# Patrol variables
var TillPatrolDistance: int = 0 # until this variable zero continue to patrol procession
var MovePatrolDirection: Vector2

var PatrolDirectionsDefault: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var PatrolDirections: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var MinNodeToPatrol: int = 3;
var MaxNodeToPatrol: int = 7;
var PatrolInProgress: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CanMove = true


func calculate_game_map_matrix() -> Array[Array]:
	var gameMapMatrix: Array[Array]
	for i in GameManager.Cells:
		var gameMapRow: Array
		for j in GameManager.Cells:
			gameMapRow.append("*")
		gameMapMatrix.append(gameMapRow)
		
	gameMapMatrix[GameManager.PlayerTankPositionData.y - 1][GameManager.PlayerTankPositionData.x] = 'd'
	
	var instanceId: String = str(get_instance_id())
	gameMapMatrix[GameManager.EnemyTankPositionData[instanceId].y - 1][GameManager.EnemyTankPositionData[instanceId].x] = 's'
	
	return gameMapMatrix


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
			
			#for i in pathToFollow:
			#	print("(", i.Row, ", ", i.Col, ") | ", i.Distance, " | BeforeNode: (", i.BeforeNode.Row, ", ", i.BeforeNode.Col, ") | ", i.BeforeNode.Distance, " | ")
			
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
	
	# If no path to destination is found, return []
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
		CurrentState = GameManager.EnemyStates.IDLE


func _on_move_timer_timeout() -> void:
	UpdatePerceptions()
	
	if CurrentState == GameManager.EnemyStates.IDLE:
		print("IDLE")
		ExecuteIdle()
	elif CurrentState == GameManager.EnemyStates.PATROL:
		print("PATROL")
		ExecutePatrol()
	elif CurrentState == GameManager.EnemyStates.CHASE:
		print("CHASE")
		ExecuteChase()


func ExecuteIdle() -> void:
	if IdleTimer.time_left == 0:
		IdleTimer.start()


func ExecutePatrol() -> void:
	if PatrolInProgress == false:
		PatrolInProgress = true
		if TillPatrolDistance == 0:
			TillPatrolDistance = randi_range(MinNodeToPatrol, MaxNodeToPatrol)
			var patrolDirectionsSize = PatrolDirections.size() - 1
			print(patrolDirectionsSize)
			var directionIndexToPatrol: int = randi_range(0, patrolDirectionsSize)
			MovePatrolDirection = PatrolDirections.pop_at(directionIndexToPatrol)
			if PatrolDirections.size() <= 0:
				print(PatrolDirectionsDefault)
				print(PatrolDirections)
				PatrolDirections = PatrolDirectionsDefault.duplicate(true)
		else:
			# Allow tank movement
			CanMove = true
			var instanceId: String = str(get_instance_id())
			# Use the player's previous position to move
			GameManager.EnemyTankPositionData[instanceId] += MovePatrolDirection
			if !check_out_of_bounds(instanceId) or check_wall_collision(instanceId):
				GameManager.EnemyTankPositionData[instanceId] -= MovePatrolDirection
			var tween: Tween = create_tween()
			tween.tween_property(GameManager.EnemyTanks[instanceId], "position", (GameManager.EnemyTankPositionData[instanceId] * GameManager.CellSize) + Vector2(0, GameManager.CellSize) , 0.18).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT);
			(GameManager.EnemyTanks[instanceId].get_node("TankBodySprite") as Sprite2D).global_rotation_degrees = rad_to_deg(MovePatrolDirection.angle()) + 90
			TillPatrolDistance = TillPatrolDistance - 1
			if TillPatrolDistance == 0:
				CurrentState = GameManager.EnemyStates.IDLE
		PatrolInProgress = false
	
func check_out_of_bounds(instanceId: String) -> bool:
	if (GameManager.EnemyTankPositionData[instanceId].x < 0 
		or GameManager.EnemyTankPositionData[instanceId].x > GameManager.Cells - 1 
		or GameManager.EnemyTankPositionData[instanceId].y < 1 
		or GameManager.EnemyTankPositionData[instanceId].y > GameManager.Cells):
		return false
	return true


func check_wall_collision(instanceId: String) -> bool:
	return GameManager.EnemyTankPositionData[instanceId] == GameManager.BaseDoorPositionData

func ExecuteChase() -> void:
	var gameMapMatrix: Array[Array] = calculate_game_map_matrix()
	shortest_path(gameMapMatrix)


func _on_idle_timer_timeout() -> void:
	if CurrentState == GameManager.EnemyStates.IDLE:
		CurrentState = GameManager.EnemyStates.PATROL
