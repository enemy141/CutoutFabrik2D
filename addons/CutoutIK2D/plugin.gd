tool
extends EditorPlugin

var bone = preload("res://addons/CutoutIK2D/Bone/Sprite_bone.gd")
var fabrik = preload("res://addons/CutoutIK2D/IK/Fabrik2D.gd")

func _enter_tree():
	add_custom_type("Fabrik", "Node2D",fabrik,get_editor_interface().get_base_control().get_icon("Node2D", "EditorIcons"))
	add_custom_type("SpriteBone", "Sprite",bone,get_editor_interface().get_base_control().get_icon("Sprite", "EditorIcons"))


func _exit_tree():
	remove_custom_type("Fabrik")
	remove_custom_type("SpriteBone")
