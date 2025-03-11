extends Node

var current_wave: int
var moving_to_next_wave: bool

var is_dragging: bool = false
var dragged_item: Node2D
var player_current_attack : bool
var item_frames_inside: Dictionary[ItemFrame, Node2D] = {}
