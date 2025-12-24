extends Node

# Player Variables
var PlayerTankPositionData: Vector2 # position for matrix
var PlayerTank: Node2D


# Bullet Variables
var BulletsPositionData: Dictionary
var Bullets: Dictionary


# Grid variables
var Cells: int = 16 # each row
var CellSize: int = 32


# Game variables
var Score: int
var GameStarted: bool = false
