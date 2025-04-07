extends Node

var current_wave: int
var moving_to_next_wave: bool

var is_dragging: bool = false
var dragged_item: Item
var player_current_attack : bool
var item_frames_inside: Dictionary[ItemFrame, Item] = {}
var luck: float = 0.0
