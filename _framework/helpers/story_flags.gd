extends Node
class_name StoryFlags

# --------------------------------------------------
# Designers add flags here
# --------------------------------------------------
## The default values for each StoryFlag.  This is also where you define each flag.
const DEFAULT_FLAGS: Dictionary = {
	"testFlag": false,
	"anotherFlag": true,
	"aThirdFlag": false,
	"doorOpen": false
}
#---------------------------------------------------

## A copy of [member DEFAULT_FLAGS] that can be modified during run time.
static var currentFlags: Dictionary = DEFAULT_FLAGS.duplicate(true)

## Allows you to check the values of multiple flags.[br][br]
## Example:
## [codeblock]
## var flagsToCheck:Dictionary = {
## 	"testFlag": false,
## 	"anotherFlag": true
## }
## 
## if StoryFlags.flagsMatch(flagsToCheck):
## 	print("All flags pass.")
## else:
## 	print("Not all flags passed.")
## [/codeblock]
## If you only need to check against one flag, you can just read [member currentFlags] directly.
## [codeblock]
## if StoryFlags.currentFlags.testFlag:
## 	print("testFlag is true")
## [/codeblock]
static func flagsMatch(flagsToCheck: Dictionary) -> bool:
	for flagID in flagsToCheck.keys():
		var currentValue: Variant = currentFlags[flagID]
		
		if currentValue != flagsToCheck[flagID]:
			print(flagID, " fails check.")
			return false
	return true

## Allows you to update the values of multiple flags.[br][br]
## Example:
## [codeblock]
## var flagsToUpdate:Dictionary = {
## 	"testFlag": false,
## 	"anotherFlag": true
## }
## 
## StoryFlags.updateFlags(flagsToUpdate)
## [/codeblock]
## If you only need to check against one flag, you can just read [member currentFlags] directly.
## [codeblock]
## StoryFlags.currentFlags.testFlag = true
## [/codeblock]
static func updateFlags(flagsToUpdate: Dictionary) -> void:
	for flagID in flagsToUpdate.keys():
		var value: Variant = flagsToUpdate[flagID]
		var currentValue: Variant = currentFlags[flagID]
		
		# support increment / decrement for int flags
		if typeof(value) == TYPE_STRING and value == "increment":
			if typeof(currentValue) == TYPE_INT:
				currentFlags[flagID] = currentValue + 1
			else:
				push_warning("StoryFlags: Tried to increment non-int flag '%s'" % flagID)
		elif typeof(value) == TYPE_STRING and value == "decrement":
			if typeof(currentValue) == TYPE_INT:
				currentFlags[flagID] = currentValue - 1
			else:
				push_warning("StoryFlags: Tried to decrement non-int flag '%s'" % flagID)
		else:
			currentFlags[flagID] = value

## Resets all flags to their default values.
static func resetFlags() -> void:
	currentFlags = DEFAULT_FLAGS.duplicate(true)
