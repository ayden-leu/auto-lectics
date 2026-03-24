extends Node
class_name StoryFlags

# --------------------------------------------------
# Designers add flags here
# --------------------------------------------------
static var default_flags: Dictionary = {
	"testFlag": false,
	"anotherFlag": true,
	"aThirdFlag": false,
	"doorOpen": false
}
#---------------------------------------------------
static var current_flags: Dictionary = default_flags.duplicate(true)

# Using flags
static func passes_check_flags(flag_data: Dictionary) -> bool:
	for flag_id in flag_data.keys():
		var current_value: Variant = current_flags[flag_id]
		
		if current_value != flag_data[flag_id]:
			print(flag_id, " fails check.")
			return false
	return true

#Updating flag upon condition met
static func apply_set_flags(flag_data: Dictionary) -> void:
	for flag_id in flag_data.keys():
		var value: Variant = flag_data[flag_id]
		var current_value: Variant = current_flags[flag_id]
		
		# support increment / decrement for int flags
		if typeof(value) == TYPE_STRING and value == "increment":
			if typeof(current_value) == TYPE_INT:
				current_flags[flag_id] = current_value + 1
			else:
				push_warning("StoryFlags: Tried to increment non-int flag '%s'" % flag_id)
		elif typeof(value) == TYPE_STRING and value == "decrement":
			if typeof(current_value) == TYPE_INT:
				current_flags[flag_id] = current_value - 1
			else:
				push_warning("StoryFlags: Tried to decrement non-int flag '%s'" % flag_id)
		else:
			current_flags[flag_id] = value

static func reset_flags() -> void:
	current_flags = default_flags.duplicate(true)
