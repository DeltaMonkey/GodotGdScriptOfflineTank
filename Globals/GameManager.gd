extends Node


# Player Variables
var PlayerTankPositionData: Vector2 # position for matrix
var PlayerTank: Node2D


# Bullet Variables
var BulletsPositionData: Dictionary
var Bullets: Dictionary


# Base Variables
var BaseDoorPositionData: Vector2 # position for matrix
var BaseDoor: Node2D


# Enemy Variables
enum EnemyStates { IDLE, PATROL, CHASE }  
var EnemyTankPositionData: Dictionary
var EnemyTanks: Dictionary


# Grid variables
var Cells: int = 16 # each row
var CellSize: int = 32


# Game variables
var Score: int
var GameStarted: bool = false
