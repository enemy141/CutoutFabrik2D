tool
extends Sprite
class_name SpriteBone,"res://addons/CutoutIK2D/Bone/Spritebone.png"

var bone_rid : RID

var draw_in_editor : bool = false
var auto_length_cal : bool = false
var auto_angle_cal : bool = false

var bone_length : float = -1.0
var bone_angle : float = 0
var line_color : Color = Color(1.0, 1.0, 0.0, 0.4)

var original_trans : Transform2D = transform

func _set(property, value):
	if property == "BONE/Length":
		bone_length = float(value)
		update_item()
		property_list_changed_notify()
		return true
	elif property == "BONE/Auto_length":
		auto_length_cal = bool(value)
		auto_cal_length()
		update_item()
		property_list_changed_notify()
		return true
	elif property == "BONE/Angle":
		bone_angle = deg2rad(float(value))
		update_item()
		property_list_changed_notify()
		return true
	elif property == "BONE/Auto_angle":
		auto_angle_cal = bool(value)
		auto_cal_angle()
		update_item()
		property_list_changed_notify()
	elif property == "BONE/Draw_line_in_editor":
		draw_in_editor = value
		if bone_rid != null:
			VisualServer.free_rid(bone_rid)
		
		bone_rid = VisualServer.canvas_item_create()
		VisualServer.canvas_item_set_parent(bone_rid,get_canvas_item())
		VisualServer.canvas_item_set_z_as_relative_to_parent(bone_rid,true)
		VisualServer.canvas_item_set_z_index(bone_rid,10)
		VisualServer.canvas_item_clear(bone_rid)
		
		update_item()
		property_list_changed_notify()
		return true
	elif property == "BONE/LineColor":
		line_color = value
		update_item()
		property_list_changed_notify()
		return true

func _get(property):
	if property == "BONE/Length":
		return bone_length
	elif property == "BONE/Auto_length":
		return auto_length_cal
	elif property == "BONE/Auto_angle":
		return auto_angle_cal
	elif property == "BONE/Angle":
		return rad2deg(bone_angle)
	elif property == "BONE/Draw_line_in_editor":
		return draw_in_editor
	elif property == "BONE/LineColor":
		return line_color

func _get_property_list():
	var list = []
	var dict : Dictionary
	dict = {'name' : "Bone Data",
			'type' : TYPE_NIL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE}
	list.append(dict)
	dict = {'name' : "BONE/Draw_line_in_editor",
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : "BONE/Auto_length",
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : "BONE/Auto_angle",
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : "BONE/Length",
			'type' : TYPE_REAL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : "BONE/Angle",
			'type' : TYPE_REAL,
			'hint' : PROPERTY_HINT_RANGE,
			'hint_string' : "-360, 360",
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : "BONE/LineColor",
			'type' : TYPE_COLOR,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	
	return list

func _notification(what):
	if what == NOTIFICATION_EXIT_TREE:
		if bone_rid != null:
			VisualServer.free_rid(bone_rid)

func _ready():
	if auto_length_cal:
		auto_cal_length()

func update_item():
	if Engine.editor_hint:
		update()

func auto_cal_length():
	var length_set = false
	
	for child in get_children():
		var child_node = child
		if child_node.is_class(self.get_class()):
			bone_length = (global_transform.origin.distance_to(child_node.global_transform.origin))
			length_set = true
			break
		
	if length_set == false:
		bone_length = -1.0

func auto_cal_angle():
	var angle_set = false
	
	for child in get_children():
		var child_node = child
		if child_node.is_class(self.get_class()):
			var child_relative_pos = child_node.transform.origin.normalized()
			bone_angle = atan2(child_relative_pos.y,child_relative_pos.x)
			angle_set = true
			break
	
	if angle_set == false:
		bone_angle = 0

func _draw():
	if Engine.editor_hint:
		if draw_in_editor:
			if bone_rid != null:
				#VisualServer.canvas_item_clear(bone_rid)
				pass
			
			var bone_direction : Vector2 = Vector2(cos(bone_angle),sin(bone_angle))
			var shape_points = [4]
			var shape_color = [4]
			var bone_d_perp = Vector2(sin(bone_angle),cos(bone_angle))
			
			
			for _i in range(4):
				shape_color.append(line_color)
				shape_points.append(Vector2.ZERO)
			
			shape_points[1] = (bone_direction * bone_length * 0.2) + (bone_d_perp * bone_length * 0.1)
			shape_points[2] = (bone_direction* bone_length)
			shape_points[3] = (bone_direction * bone_length * 0.2) - (bone_d_perp * bone_length * 0.1)
			
			VisualServer.canvas_item_add_polygon(bone_rid,shape_points,shape_color)
