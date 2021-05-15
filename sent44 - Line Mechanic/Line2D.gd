extends Line2D

onready var map :TileMap = get_parent()

var map_data          :Dictionary = {}
var current_node      :MapNode
var current_last_node :MapNode

var cell_size    :int = 32
var offset       :Vector2 = Vector2(16,16)
var line_offset  :Vector2 = position - offset
var line_nodes   :Array
var start_pos    :Vector2 = position


class MapNode:
	var position: Vector2
	var chain :Array
	var next: MapNode


func _ready() -> void:
	print(map.get_used_rect())
	var rect_offset_x = map.get_used_rect().position.x
	var rect_offset_y = map.get_used_rect().position.y

	for x in range(map.get_used_rect().size.x + rect_offset_x):
		for y in range(map.get_used_rect().size.y + rect_offset_y):
			if map.get_cell(x,y) != -1:
				var node: MapNode = MapNode.new()
				node.position = Vector2(x * cell_size, y * cell_size) - line_offset
				node.chain = get_adjacent_cells(x,y) 

				map_data[Vector2(x, y)] = node

	#set start_node
	current_node = map_data[map.world_to_map(start_pos)]
	current_last_node = current_node

#used to check if mouse_tile is adjacent to the curr_node
func get_adjacent_cells(x,y) -> Array:
	var array:Array
	for dir in [Vector2.UP,Vector2.LEFT,Vector2.DOWN,Vector2.RIGHT]:
		var next_cell = Vector2(x,y)+dir
		if map.get_cellv(next_cell) != -1:
			array.append(next_cell)
	return array

func get_map_node_from_position(mouse_pos):
	var mouse_tile_pos = map.world_to_map(mouse_pos)

	if map.get_cellv(mouse_tile_pos) != -1:
		var new_input :MapNode = map_data[mouse_tile_pos]

		if new_input == current_last_node:
			#update_line_pos, this is going to be so complicated for corners the line should move like a liquid filling a tube.
			pass

		if current_last_node.chain.has(mouse_tile_pos):
#			print("new_input: ",map_data[mouse_tile_pos]," last_node: ",current_last_node)
			current_last_node.next = new_input
			return new_input
	return


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
	
	if event is InputEventMouseMotion:
		var new_input :MapNode = get_map_node_from_position( get_global_mouse_position() )
		
		if new_input is MapNode && current_last_node is MapNode:

			#This is reading outdated data from a node and keeps 
			#deleting nodes in the path backwards even if you are not backtracking anymore
			if new_input.next == current_last_node: 
				printerr("delete")
				current_last_node = new_input
				current_last_node.next = null 
				remove_point(get_point_count()-1)

			else:
				print("create")
				current_last_node.next = new_input
				current_last_node = new_input
				add_point(new_input.position)
