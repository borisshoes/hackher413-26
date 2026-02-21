extends Node

@export var recipes:Array[Recipe]

func match_recipe(input:Array[String]) -> Recipe:
	for recipe in recipes:
		if recipe.ingredients == input:
			return recipe
	return null
