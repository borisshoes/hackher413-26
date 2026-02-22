extends Node

@export var recipes:Array[Recipe]

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
