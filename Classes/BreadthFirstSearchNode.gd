class_name BreadthFirstSearchNode extends Node

var Row: int
var Col: int
var Distance: int
var BeforeNode: BreadthFirstSearchNode

func create(row: int, col: int, distance: int, beforeNode: BreadthFirstSearchNode = null) -> BreadthFirstSearchNode:
	Row = row
	Col = col
	Distance = distance
	BeforeNode = beforeNode
	return self
