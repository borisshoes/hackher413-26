extends StaticBody3D

var player_holding = null
var transit = null
var local_player = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.item = null
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	local_player = NetHandler.local_player
	pass

#function to handle adding items to the counter, takes in one argument, the item tthat the player is holding
func interact(item) -> void:
	#if counter has no item and player has item, put item on counter
	if self.item == null && local_player.holding_something != null:
		self.item = item
		local_player.holding_something = null
	#if counter has item and player has no item, pick up item from counter
	elif self.item != null && local_player.holding_something == null:
		local_player.holding_something = self.item
		self.item = null
	#if counter has item and player has item, swap items
	elif self.item != null && local_player.holding_something != null:
		transit = self.item.duplicate()
		self.item = local_player.holding_something
		local_player.holding_something = transit
	return
