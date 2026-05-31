@icon("uid://cd5jlaus7ngf7")
extends Node
class_name StoryFlags
## Stores and updates global story flags.
##
## This class provides a central place for tracking story-related values that
## need to be accessed by multiple scripts.
##
##
##
## [br][br][br]
## [b]Use Case[/b][br]
## Use story flags for simple global state, such as whether an NPC has been spoken to,
## whether a door should open, or whether a dialogue option should be available.
##
##
##
## [br][br][br]
## [b]How to Use[/b][br]
## Designers should define new flags by adding them to [member DEFAULT_FLAGS].
## Scripts can then read from [member currentFlags], check multiple flags with
## [method flagsMatch], or update multiple flags with [method updateFlags].
## [br][br]
## Dialogue options can also use story flags through their [code]checkFlags[/code]
## and [code]setFlags[/code] fields. [code]checkFlags[/code] controls whether an
## option should appear, while [code]setFlags[/code] updates flags when an option
## is chosen.
##
##
##
## [br][br][br]
## [b]Important Notes[/b][br]
## Every flag that will be checked or updated should be defined in
## [member DEFAULT_FLAGS]. If a script tries to access a flag that does not exist,
## it may cause an error.
## [br][br]
## [method updateFlags] also supports [code]"increment"[/code] and
## [code]"decrement"[/code] for integer flags.


# --------------------------------------------------
# Designers add flags here
# --------------------------------------------------

## The default values for each story flag.
## [br][br]
## This is also where each flag is defined. Add new flags here before checking
## or updating them anywhere else in the project.
## [br][br]
## The key is the flag ID, and the value is the flag's default value.
## Values should be booleans or integers.
## [br][br]
## Boolean flags are useful for yes/no story states, while
## integer flags are useful for counters, such as how many times something
## has happened.
const DEFAULT_FLAGS: Dictionary = {
	"testFlag": false,
	"anotherFlag": true,
	"aThirdFlag": false,
	"doorOpen": false
}
#---------------------------------------------------

## A modifiable copy of [member DEFAULT_FLAGS].
## [br][br]
## This dictionary stores the current runtime values of all story flags. It is
## reset back to [member DEFAULT_FLAGS] when [method resetFlags] is called.
static var currentFlags: Dictionary = DEFAULT_FLAGS.duplicate(true)

## Checks whether multiple flags match the expected values.
## [br][br]
## [param flagsToCheck] should be a dictionary where each key is a flag ID and
## each value is the value that flag is expected to have.
## [br][br]
## Returns [code]true[/code] if every listed flag matches its expected value.
## Returns [code]false[/code] as soon as one flag does not match.
## [br][br]
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
			print(flagID, " fails check. (is ", currentValue, ", check is ", flagsToCheck[flagID], ")")
			return false
	return true

## Updates multiple story flags.
## [br][br]
## [param flagsToUpdate] should be a dictionary where each key is a flag ID and
## each value is the new value for that flag.
## [br][br]
## If the update value is [code]"increment"[/code] or [code]"decrement"[/code],
## and the current flag value is an integer, the flag will increase or decrease
## by 1 instead of being set directly.
## [br][br]
## Example:
## [codeblock]
## var flagsToUpdate:Dictionary = {
## 	"testFlag": false,
## 	"anotherFlag": true
## }
##
## StoryFlags.updateFlags(flagsToUpdate)
## [/codeblock]
## If you only need to update one flag, you can write to [member currentFlags] directly.
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

## Resets all story flags to their default values.
## [br][br]
## This replaces [member currentFlags] with a fresh duplicate of
## [member DEFAULT_FLAGS].
static func resetFlags() -> void:
	currentFlags = DEFAULT_FLAGS.duplicate(true)
