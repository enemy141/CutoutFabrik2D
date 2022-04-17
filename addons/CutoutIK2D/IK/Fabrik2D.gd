tool
extends Node2D

var path_to_target : NodePath 
var path_to_char : NodePath

var target_node : Node2D 
var target_transform : Transform2D

var chain_tolerance : float = 2.0
var chain_max_iterations : int = 10

var enable_editor : bool = false
var constraint_mode : bool = true

class FABRIK_JOINT:
	var path_to_bone : NodePath
	var bone_node : SpriteBone
	var magnet_position : Vector2 = Vector2.ZERO
	var use_target_rotation : bool
	
	var enable_constraint = false
	var constraint_angle_min = 0.0
	var constraint_angle_max = 2.0 * PI
	var constraint_angle_invert = false
	var constraint_in_localspace = true

var fabrik_joint: Array = []
var fabrik_transfroms : Array = []
var local_position : Array = []

var num : int = 0

func _set(property, value):
	if property == "Enable_On_Editor":
		enable_editor = value
		property_list_changed_notify()
		return true
	elif property == "FABRIK/target":
		path_to_target = value
		if path_to_target != null:
			target_node = get_node_or_null(path_to_target)
			property_list_changed_notify()
		return true
	elif property == "FABRIK/Draw_Constraint":
		constraint_mode = value
		property_list_changed_notify()
		return true
	elif property == "FABRIK/Max_Iterations":
		chain_max_iterations = value
		property_list_changed_notify()
		return true
	elif property == "FABRIK/joint_count":
		num = value
		
		if num < 0:
			num = 0
		
		var new_array = []
		var new_local = []
		
		for _i in range(num):
			new_array.append(FABRIK_JOINT.new())
			new_local.append(Vector2.ZERO)
		
		fabrik_joint = new_array
		local_position = new_local
		
		var new_fabrik_transfroms_array = []
		
		for _i in range(num):
			new_fabrik_transfroms_array.append(Transform2D.IDENTITY)
		
		fabrik_transfroms = new_fabrik_transfroms_array
		
		property_list_changed_notify()
		return true
	elif property.begins_with("FABRIK/joint/"):
		var fabrik_data = property.split("/")
		var joint_index = fabrik_data[2].to_int()
		
		if(joint_index < 0 || joint_index >  fabrik_data.size() - 1):
			printerr("ERROR - Cannot get FABRIK joint at index " + joint_index.to_string())
			return false
		
		var current_joint : FABRIK_JOINT = fabrik_joint[joint_index]
		
		if fabrik_data[3] == "bone_node":
			current_joint.path_to_bone = value
			
			if current_joint.path_to_bone != null:
				current_joint.bone_node = get_node_or_null(current_joint.path_to_bone)
			fabrik_joint[joint_index] = current_joint
			property_list_changed_notify()
		elif fabrik_data[3] == "magnet_position":
			current_joint.magnet_position = value
			fabrik_joint[joint_index] = current_joint
			property_list_changed_notify()
		elif fabrik_data[3] == "use_target_rotation":
			current_joint.use_target_rotation = value
			fabrik_joint[joint_index] = current_joint
			property_list_changed_notify()
		elif fabrik_data[3] == "enable_constraint":
			current_joint.enable_constraint = value
			fabrik_joint[joint_index] = current_joint
			property_list_changed_notify()
		elif fabrik_data[3] == "angle_min":
			var current_value = value
			current_joint.constraint_angle_min = deg2rad(float(current_value))
			fabrik_joint[joint_index] = current_joint
			property_list_changed_notify()
		elif fabrik_data[3] == "angle_max":
			var current_value = value
			current_joint.constraint_angle_max = deg2rad(float(current_value))
			fabrik_joint[joint_index] = current_joint
			property_list_changed_notify()
		elif fabrik_data[3] == "constraint_invert":
			current_joint.constraint_angle_invert = value
			fabrik_joint[joint_index] = current_joint
			property_list_changed_notify()
		elif fabrik_data[3] == "constraint_in_localspace":
			current_joint.constraint_in_localspace= value
			fabrik_joint[joint_index] = current_joint
			property_list_changed_notify()
		return true

func _get(property):
	if property == "Enable_On_Editor":
		return enable_editor
	elif property == "FABRIK/target":
		return path_to_target
	elif property == "FABRIK/Draw_Constraint":
		return constraint_mode
	elif property == "FABRIK/Max_Iterations":
		return chain_max_iterations
	elif property == "FABRIK/joint_count":
		return num
	elif property.begins_with("FABRIK/joint/"):
		var fabrik_data = property.split("/")
		var joint_index = fabrik_data[2].to_int()
		if fabrik_data[3] == "bone_node":
			return fabrik_joint[joint_index].path_to_bone
		elif fabrik_data[3] == "magnet_position":
			return fabrik_joint[joint_index].magnet_position
		elif fabrik_data[3] == "enable_constraint":
			return fabrik_joint[joint_index].enable_constraint
		elif fabrik_data[3] == "angle_min":
			return rad2deg(fabrik_joint[joint_index].constraint_angle_min)
		elif fabrik_data[3] == "angle_max":
			return rad2deg(fabrik_joint[joint_index].constraint_angle_max)
		elif fabrik_data[3] == "constraint_invert":
			return fabrik_joint[joint_index].constraint_angle_invert
		elif fabrik_data[3] == "constraint_in_localspace":
			return fabrik_joint[joint_index].constraint_in_localspace
		elif fabrik_data[3] == "use_target_rotation":
			return fabrik_joint[joint_index].use_target_rotation

func _get_property_list():
	var list = []
	var dict : Dictionary
	var string = "FABRIK/joint/"
	dict = {'name' : "FABRIK_CONSTRAINT",
			'type' : TYPE_NIL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE}
	list.append(dict)
	dict = {'name' : "Enable_On_Editor",
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : 'FABRIK/target',
			'type' : TYPE_NODE_PATH,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : "FABRIK/Draw_Constraint",
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : "FABRIK/Max_Iterations",
			'type' : TYPE_INT,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	dict = {'name' : 'FABRIK/joint_count',
			'type' : TYPE_INT,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
	list.append(dict)
	for i in num:
		dict = {'name' : string + str(i) + '/bone_node',
				'type' : TYPE_NODE_PATH,
				'hint' : PROPERTY_HINT_NONE,
				'usage' : PROPERTY_USAGE_DEFAULT}
		list.append(dict)
		dict = {'name' : string + str(i) + '/magnet_position',
				'type' : TYPE_VECTOR2,
				'hint' : PROPERTY_HINT_NONE,
				'usage' : PROPERTY_USAGE_DEFAULT}
		list.append(dict)
		dict = {'name' : string + str(i) + '/enable_constraint',
				'type' : TYPE_BOOL,
				'hint' : PROPERTY_HINT_NONE,
				'usage' : PROPERTY_USAGE_DEFAULT}
		list.append(dict)
		if fabrik_joint[i].enable_constraint == true:
			dict = {'name' : string + str(i) + '/angle_min',
				'type' : TYPE_REAL,
				'hint' : PROPERTY_HINT_RANGE,
				'hint_string' : "-360, 360",
				'usage' : PROPERTY_USAGE_DEFAULT}
			list.append(dict)
			dict = {'name' : string + str(i) + '/angle_max',
				'type' : TYPE_REAL,
				'hint' : PROPERTY_HINT_RANGE,
				'hint_string' : "-360, 360",
				'usage' : PROPERTY_USAGE_DEFAULT}
			list.append(dict)
			dict = {'name' : string + str(i) + '/constraint_invert',
				'type' : TYPE_BOOL,
				'hint' : PROPERTY_HINT_NONE,
				'usage' : PROPERTY_USAGE_DEFAULT}
			list.append(dict)
			dict = {'name' : string + str(i) + '/constraint_in_localspace',
				'type' : TYPE_BOOL,
				'hint' : PROPERTY_HINT_NONE,
				'usage' : PROPERTY_USAGE_DEFAULT}
			list.append(dict)
		if i == fabrik_joint.size() - 1:
			dict = {'name' : string + str(i) + '/use_target_rotation',
			'type' : TYPE_BOOL,
			'hint' : PROPERTY_HINT_NONE,
			'usage' : PROPERTY_USAGE_DEFAULT}
			list.append(dict)
		
	return list

func _draw():
	if Engine.editor_hint and constraint_mode:
		for i in fabrik_joint.size():
			var current : FABRIK_JOINT = fabrik_joint[i]
			draw_angle_const(current.bone_node,current.constraint_angle_min,current.constraint_angle_max,
												current.enable_constraint,current.constraint_in_localspace,current.constraint_angle_invert)

func _ready():
	if path_to_target != null:
		target_node = get_node_or_null(path_to_target)

# warning-ignore:unused_argument
func _physics_process(delta):
	if enable_editor == true:
		if Engine.editor_hint:
			executetion()
	if not Engine.editor_hint:
		executetion()
	update()

func executetion():
	if target_node == null:
		assert(false,"Cannot execute : No target found!")
		return 
	
	if fabrik_joint.size() <= 0:
		assert(false,"Cannot execute : No joints found!")
		return 
	
	var all_of_joint = fabrik_joint.size()
	
	for i in all_of_joint:
		var current_joint : FABRIK_JOINT = fabrik_joint[i]
		if current_joint.bone_node == null:
			current_joint.bone_node = get_node_or_null(current_joint.path_to_bone)
			if current_joint.bone_node == null:
				assert(false,"Cannot find boneIK2D for joint: " + str(i))
				return 
			fabrik_joint[i] = current_joint
		if current_joint.bone_node.bone_length == 0:
			assert(false,"Cannot execute boneIK2D for joint: " +  str(i) + " cause no bone length")
			return 
		fabrik_transfroms[i] = current_joint.bone_node.global_transform
		local_position[i] = current_joint.bone_node.position
	
	target_transform = target_node.global_transform
	
	for i in all_of_joint:
		if i != fabrik_joint.size() - 1:
			local_position[i + 1] = Vector2(fabrik_joint[i].bone_node.bone_length,fabrik_joint[i + 1].bone_node.position.y)
	
	var final_bone_index : int = fabrik_joint.size() - 1
	var final_joint_node : FABRIK_JOINT = fabrik_joint[final_bone_index]
	
	#if !final_joint_node.use_target_rotation:
		#final_joint_node.bone_node.look_at(target_node.global_position)
	
	var final_joint_angle = final_joint_node.bone_node.global_rotation
	
	if(fabrik_joint[final_bone_index].use_target_rotation):
		final_joint_angle = target_transform.get_rotation()
	
	var final_joint_direction = Vector2(cos(final_joint_angle),sin(final_joint_angle))
	var final_joint_length = fabrik_joint[final_bone_index].bone_node.bone_length
	var target_distance = (final_joint_node.bone_node.global_position + 
		(final_joint_direction * final_joint_length)).distance_to(target_node.global_position)
	
	var chain_iterations : int = 0
	
	while (target_distance > chain_tolerance):
		chain_backward()
		chain_forward()
		apply_all_joint_node()
		
		chain_iterations += 1
		if chain_iterations >= chain_max_iterations:
			break


func chain_backward():
	var final_bone_index : int = fabrik_joint.size() - 1
	var final_joint_trans : Transform2D = fabrik_transfroms[final_bone_index]
	
	if !fabrik_joint[final_bone_index].use_target_rotation:
		fabrik_joint[final_bone_index].bone_node.look_at(target_node.global_position)
		final_joint_trans = fabrik_joint[final_bone_index].bone_node.global_transform
	
	var final_joint_angle  = final_joint_trans.get_rotation()
	var final_bone_angle_vector = Vector2(cos(final_joint_angle),sin(final_joint_angle))
	
	if final_bone_index != 0:
		final_joint_trans.origin = final_joint_trans.origin + fabrik_joint[final_bone_index].magnet_position
	
	final_joint_trans.origin = target_transform.origin - (final_bone_angle_vector * fabrik_joint[final_bone_index].bone_node.bone_length)
	fabrik_transfroms[final_bone_index] = final_joint_trans
	
	
	for i in range(final_bone_index,0,-1):
		
		var previous_bone_trans : Transform2D = fabrik_transfroms[i]
		var current_bone_trans : Transform2D = fabrik_transfroms[i - 1]
		
		if i !=0:
			current_bone_trans.origin = current_bone_trans.origin + fabrik_joint[i - 1].magnet_position
		
		var length = fabrik_joint[i-1].bone_node.bone_length / current_bone_trans.origin.distance_to(previous_bone_trans.origin)
		current_bone_trans.origin = previous_bone_trans.origin.linear_interpolate(current_bone_trans.origin,length)
		fabrik_transfroms[i-1] = current_bone_trans

func chain_forward():
	for i in fabrik_joint.size() - 1:
		
		var next_bone_trans : Transform2D = fabrik_transfroms[i + 1]
		var current_bone_trans : Transform2D = fabrik_transfroms[i]
		
		var length = fabrik_joint[i].bone_node.bone_length / next_bone_trans.origin.distance_to(current_bone_trans.origin)
		
		next_bone_trans.origin = current_bone_trans.origin.linear_interpolate(next_bone_trans.origin,length)
		fabrik_transfroms[i+1] = next_bone_trans

func apply_all_joint_node():
	for i in fabrik_joint.size():
		fabrik_joint[i].bone_node.global_transform = fabrik_transfroms[i]
		
		if (i == fabrik_joint.size() - 1):
			if(fabrik_joint[i].use_target_rotation):
				fabrik_joint[i].bone_node.rotation = target_node.rotation
			else:
				fabrik_joint[i].bone_node.look_at(target_transform.origin)
		else:
			var next_bone_trans : Transform2D = fabrik_transfroms[i+1]
			fabrik_joint[i].bone_node.look_at(next_bone_trans.origin)
		
		if fabrik_joint[i].enable_constraint:
			var current_joint : FABRIK_JOINT = fabrik_joint[i]
			current_joint.bone_node.rotation = chain_clamp_angle(current_joint.bone_node.rotation,current_joint.constraint_angle_min,
																current_joint.constraint_angle_max,current_joint.constraint_angle_invert)
			fabrik_joint[i] = current_joint
		
		fabrik_joint[i].bone_node.position = local_position[i]
		fabrik_transfroms[i] = fabrik_joint[i].bone_node.global_transform


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
	
	var ik_color =  Color(1.0, 1.0, 0.0, 0.4)
	
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

