tool
extends EditorPlugin

var fabrik = preload("res://addons/CutoutIK2D/IK/Fabrik2D.gd")

func _enter_tree():
	add_custom_type("Fabrik", "Node2D",fabrik,preload("res://addons/CutoutIK2D/IK/Fabrik.png"))


func _exit_tree():
	remove_custom_type("Fabrik")
