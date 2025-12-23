extends Node

# Player Positions
var PlayerTankPositionData: Vector2 # position for matrix
var PlayerTank: Node2D


# Grid variables
var Cells: int = 16 # each row
var CellSize: int = 32

# Game variables
var Score: int
var GameStarted: bool = false
