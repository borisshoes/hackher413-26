extends Node

@export var recipes:Array[Recipe]

func _ready():
	_load_recipes()

func _load_recipes():
	var dir = DirAccess.open("res://assets/recipes/")
	if dir == null:
		push_error("[BrewDatabase] Could not open recipes directory")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var recipe = load("res://assets/recipes/" + file_name) as Recipe
			if recipe != null:
				recipes.append(recipe)
				print("[BrewDatabase] Loaded recipe: %s" % recipe.recipe_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	print("[BrewDatabase] Loaded %d recipes total" % recipes.size())

func match_recipe(input:Array) -> Recipe:
	for recipe in recipes:
		var matches = true
		if recipe.ingredients.size() != input.size():
			continue
		for i in range(input.size()):
			if recipe.ingredients[i] != input[i]:
				matches = false
				break
		if matches:
			return recipe
	return null
