extends Node
class_name StoryFlags

# --------------------------------------------------
# Designers add flags here
# --------------------------------------------------
static var _default_flags: Dictionary = {
	"testFlag": false
}
#---------------------------------------------------
static var flagDict: Dictionary = _default_flags.duplicate(true)

# Dynamic access to flags
#static func has_flag(flag_name: String) -> bool:
	#return flagDict.has(flag_name)

#static func get_flag(flag_name: String) -> Variant:
	#if not flagDict.has(flag_name):
		#push_warning("StoryFlags: Unknown flag '%s'" % flag_name)
		#return null
	#return flagDict[flag_name]

#static func set_flag(flag_name: String, value: Variant) -> void:
	#if not flagDict.has(flag_name):
		#push_warning("StoryFlags: Unknown flag '%s'" % flag_name)
		#return
	#flagDict[flag_name] = value
	#print("Set ", flag_name, " to ", value, ".")

# Using flags
static func passes_check_flags(flags: Array) -> bool:
	for flag_data in flags:
		if typeof(flag_data) != TYPE_DICTIONARY:
			continue
		
		var flag_name: String = str(flag_data.get("flagName", ""))
		var expected_value: Variant = flag_data.get("value")
		#var current_value: Variant = get_flag(flag_name)
		var current_value: Variant = flagDict[flag_name]
		
		if current_value != expected_value:
			print(flag_name, " fails check.")
			return false
	return true

#Updating flag upon condition met
static func apply_set_flags(flags: Array) -> void:
	for flag_data in flags:
		if typeof(flag_data) != TYPE_DICTIONARY:
			continue
		
		var flag_name: String = str(flag_data.get("flagName", ""))
		var value: Variant = flag_data.get("value")
		#var current_value: Variant = get_flag(flag_name)
		var current_value: Variant = flagDict[flag_name]
		
		# support increment / decrement for int flags
		if typeof(value) == TYPE_STRING and value == "increment":
			if typeof(current_value) == TYPE_INT:
				#set_flag(flag_name, current_value + 1)
				flagDict[flag_name] = current_value + 1
			else:
				push_warning("StoryFlags: Tried to increment non-int flag '%s'" % flag_name)
		elif typeof(value) == TYPE_STRING and value == "decrement":
			if typeof(current_value) == TYPE_INT:
				#set_flag(flag_name, current_value - 1)
				flagDict[flag_name] = current_value - 1
			else:
				push_warning("StoryFlags: Tried to decrement non-int flag '%s'" % flag_name)
		else:
			#set_flag(flag_name, value)
			flagDict[flag_name] = value

static func reset_flags() -> void:
	flagDict = _default_flags.duplicate(true)
