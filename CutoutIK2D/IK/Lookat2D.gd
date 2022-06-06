tool
extends Node2D
class_name Lookat2D , "res://addons/CutoutIK2D/IK/Lookat.png"

var path_to_target : NodePath 
var target_node : Node2D 

var path_to_bone : NodePath
var bone_node : SpriteBone

var enable_exec : bool = true 
var enable_editor : bool = false
var constraint_mode : bool = true
var additional_rotation : float = 0

var enable_constraint : bool = false
var constraint_angle_min : float = 0.0
var constraint_angle_max : float = 2.0 * PI
var constraint_angle_invert : bool = false
var constraint_in_localspace : bool = true
 
var constraint_color : Color = Color(1.0, 1.0, 0.0, 0.4)

func _set(property, value):
	if property == "Enable_In_Game":
		enable_exec = value
		property_list_changed_notify()
		return true
		
	elif property == "Enable_On_Editor":
		enable_editor = value
		property_list_changed_notify()
		return true
		
	elif property == "Look_at/Draw_Constraint":
		constraint_mode = value
		property_list_changed_notify()
		return true
		
	elif property == "Look_at/target":
		path_to_target = value
		if path_to_target != null:
			target_node = get_node_or_null(path_to_target)
			property_list_changed_notify()
		return true
	
	elif property == "Look_at/bone_node":
		path_to_bone = value
		if path_to_bone != null:
			bone_node = get_node_or_null(path_to_bone)
			property_list_changed_notify()
		return true
		
	elif property == "Look_at/additional_rotation":
		additional_rotation = deg2rad(value)
		property_list_changed_notify()
		return true
		
	elif property == "Look_at/enable_constraint":
		enable_constraint = value
		property_list_changed_notify()
		return true
		
	elif property == "Look_at/Constraint_LineColor":
		constraint_color = value
		property_list_changed_notify()
		return true
		
	elif property == "Look_at/angle_min":
		constraint_angle_min = deg2rad(value)
		property_list_changed_notify()
		return true
		
	elif property == "Look_at/angle_max":
		constraint_angle_max = deg2rad(value)
		property_list_changed_notify()
		return true
		
	elif property == "Look_at/constraint_invert":
		constraint_angle_invert = value
		property_list_changed_notify()
		return true
		
	elif property == "Look_at/constraint_in_localspace":
		constraint_in_localspace = value
		property_list_changed_notify()
		return true

func _get(property):
	if property == "Enable_In_Game":
		return enable_exec
	elif property == "Enable_On_Editor":
		return enable_editor
	elif property == "Look_at/Draw_Constraint":
		return constraint_mode
	elif property == "Look_at/Constraint_LineColor":
		return constraint_color
	elif property == "Look_at/target":
		return path_to_target
	elif property == "Look_at/bone_node":
		return path_to_bone
	elif property == "Look_at/additional_rotation":
		return rad2deg(additional_rotation)
	elif property == "Look_at/enable_constraint":
		return enable_constraint
	elif property == "Look_at/angle_min":
		return rad2deg(constraint_angle_min)
	elif property == "Look_at/angle_max":
		return rad2deg(constraint_angle_max)
	elif property == "Look_at/constraint_invert":
		return constraint_angle_invert
	elif property == "Look_at/constraint_in_localspace":
		return constraint_in_localspace

func _get_property_list():
	var list = []
	var dict : Dictionary
	dict = {'name' : "Look_AT",
			'type' : TYPE_NIL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE}
	list.append(dict)
	dict = {'name' : "Enable_In_Game",
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : "Enable_On_Editor",
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : "Look_at/Draw_Constraint",
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : "Look_at/Constraint_LineColor",
			'type' : TYPE_COLOR,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : 'Look_at/target',
			'type' : TYPE_NODE_PATH,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : 'Look_at/bone_node',
			'type' : TYPE_NODE_PATH,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : 'Look_at/additional_rotation',
			'type' : TYPE_REAL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : 'Look_at/enable_constraint',
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	if enable_constraint == true:
		dict = {'name' : 'Look_at/angle_min',
			'type' : TYPE_REAL,
			'hint' : PROPERTY_HINT_RANGE,
			'hint_string' : "-360, 360, 0.01",
			'usage' : PROPERTY_USAGE_DEFAULT}
		list.append(dict)
		dict = {'name' : 'Look_at/angle_max',
			'type' : TYPE_REAL,
			'hint' : PROPERTY_HINT_RANGE,
			'hint_string' : "-360, 360, 0.01",
			'usage' : PROPERTY_USAGE_DEFAULT}
		list.append(dict)
		dict = {'name' : 'Look_at/constraint_invert',
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
		list.append(dict)
		dict = {'name' : 'Look_at/constraint_in_localspace',
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
		list.append(dict)
	
	return list

func _draw():
	if Engine.editor_hint and constraint_mode:
		draw_angle_const(bone_node,constraint_angle_min,constraint_angle_max,
						enable_constraint,constraint_in_localspace,constraint_angle_invert)

func _ready():
	if path_to_target != null:
		target_node = get_node_or_null(path_to_target)
	
	if path_to_bone != null:
		bone_node = get_node_or_null(path_to_bone)

func _physics_process(delta):
	if enable_editor == true:
		if Engine.editor_hint:
			executetion()
	elif enable_exec == true:
		if not Engine.editor_hint:
			executetion()
	update()

func executetion():
	if target_node == null:
		assert(false,"Cannot execute : No target found!")
		return
	
	if bone_node == null:
		assert(false,"Cannot execute : No bone node found!")
		return
	
	var target_transform = target_node.global_transform
	
	bone_node.look_at(target_transform.origin)
	
	if enable_constraint:
		bone_node.rotation = chain_clamp_angle(bone_node.rotation,constraint_angle_min,
												constraint_angle_max,constraint_angle_invert)
	
	bone_node.rotate(additional_rotation)
	bone_node.rotate(-bone_node.bone_angle)

func chain_clamp_angle(p_angle : float,p_min_bound : float,p_max_bound : float,p_invert : bool):
	if p_angle < 0:
		p_angle = TAU + p_angle
	
	if p_min_bound < 0:
		p_min_bound = TAU + p_min_bound
	
	if p_max_bound < 0:
		p_max_bound = TAU + p_max_bound
	
	if (p_min_bound > p_max_bound):
		var temp = p_min_bound
		p_min_bound = p_max_bound
		p_max_bound = temp
	
	var is_beyond_bounds : bool = (p_angle < p_min_bound || p_angle > p_max_bound)
	var is_within_bounds : bool = (p_angle > p_min_bound && p_angle < p_max_bound)
	
	if !p_invert && is_beyond_bounds || p_invert && is_within_bounds:
		var min_bound_vec : Vector2 = Vector2(cos(p_min_bound),sin(p_min_bound))
		var max_bound_vec : Vector2 = Vector2(cos(p_max_bound),sin(p_max_bound))
		var angle_vec : Vector2 = Vector2(cos(p_angle),sin(p_angle))
		
		if angle_vec.distance_squared_to(min_bound_vec) <= angle_vec.distance_squared_to(max_bound_vec):
			p_angle = p_min_bound
		else:
			p_angle = p_max_bound
	return p_angle

func draw_angle_const(bone : SpriteBone,min_bound : float,max_bound : float,const_enable : bool,const_in_local : bool,const_inverted : bool):
	if !bone:
		return 0
	
	var ik_color = constraint_color
	
	var arc_angle_min = min_bound
	var arc_angle_max = max_bound
	
	if arc_angle_min < 0:
		arc_angle_min = PI * 2 + arc_angle_min
	
	if arc_angle_max < 0:
		arc_angle_max = PI * 2 + arc_angle_max
	
	if arc_angle_min > arc_angle_max:
		var temp = arc_angle_min
		arc_angle_min = arc_angle_max
		arc_angle_max = temp
	
	if const_enable:
		if const_in_local:
			var bone_parent = bone.get_parent()
			
			if bone_parent != null:
				draw_set_transform(get_global_transform().affine_inverse().xform(bone.global_position),bone.global_rotation - global_rotation,Vector2.ONE)
			else:
				draw_set_transform(get_global_transform().affine_inverse().xform(bone.global_position),0,Vector2.ONE)
		else:
			draw_set_transform(get_global_transform().affine_inverse().xform(bone.global_position),0,Vector2.ONE)
		
		if const_inverted:
			draw_arc(Vector2.ZERO,bone.bone_length, arc_angle_min +  PI * 2.0,arc_angle_max,32,ik_color,1.0)
		else:
			draw_arc(Vector2.ZERO,bone.bone_length, arc_angle_min,arc_angle_max,32,ik_color,1.0)
		
		draw_line(Vector2.ZERO,Vector2(cos(arc_angle_min),sin(arc_angle_min)) * bone.bone_length,ik_color,1.0)
		draw_line(Vector2.ZERO,Vector2(cos(arc_angle_max),sin(arc_angle_max)) * bone.bone_length,ik_color,1.0)
		
	else:
		draw_set_transform(get_global_transform().affine_inverse().xform(bone.global_position),0,Vector2.ONE)
		draw_arc(Vector2.ZERO,bone.bone_length,0,PI * 2.0,32,ik_color,1.0)
		draw_line(Vector2.ZERO,Vector2.UP * bone.bone_length,ik_color,1.0)

