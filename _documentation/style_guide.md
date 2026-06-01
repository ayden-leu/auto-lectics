These are just soft guidelines.  Don't stress about following them 100%.  I just think it'd make the code slightly more clean, even if it'd just be the smallest of slight improvements.

# Code Layout
When defining things like variables and functions, they should be laid out like so:
```gdscript
# extends ___, if it extends another class
# class_name ___, if you plan on referring to members of this script regularly

# signals
# enums
# constants
# export variables
# onready variables
# normal variables
# functions referenced outside of this script
# functions only referenced inside this script
# functions that run when a signal is emitted
# editor dev-ing functions like "_get_configuration_warnings()"
```
You can either type each section out manually, or select the `Recommended Script Template` from the `Template` field when creating a new script.

# Class Name
Name using `PascalCase` to match Godot's naming convention of nodes.
```gdscript
class_name MyNewClass
```

# Signals
Name using `snake_case`.
```gdscript
signal this_is_snake_case()
signal thisIsntSnakeCase()
```

Name based on when it'll be called.  For example, let's setup a signal that emits when a node's state is fully updated.  This helps with figuring out what a signal's purpose is.
```gdscript
signal fully_updated()
```

If you want to send data along with your signal, you should define its parameters like you do with functions.  This helps with figuring out what a signal's purpose is, while also making sure you don't connect the signal to a function that doesn't expect data.
```gdscript
signal received_data(data:Dictionary)
```
If you don't want to send data with this signal, you should still have a `()` at the end to signify such.

If the signal is not supposed to be referenced outside of the script (e.g  a signal that is used by a node to notify itself that a local function is finished), then prefix the signal with a `_`.  This has the added benefit of not appearing in the auto-generated documentation.
```gdscript
signal _nodes_finished_moving
```

When connecting signals to functions, use `[signal_name].connect(function_name)`.  `function_name` should also be prefixed with `_on_`.
```gdscript
someNode.is_fully_ready.connect(_on_some_node_fully_ready)
```

# Variables
These rules apply to all sub-types as well unless specified otherwise.

Name using `camelCase`.
```gdscript
var thisIsCamelCase
var ThisIsNotCamelCase
var nor_is_this
var OR_THIS
```

Name based on their purpose.  Let's create a variable for keeping track of a previous position as an example.
```gdscript
var aspectOne:Vector3
# bad

var playersPreviousPosition:Vector3
# better, but it has some redundant wording.
# if you were referencing this variable somewhere else, it'd look like Player.playersPreviousPosition
# the "s" in "players" also makes it look like it stores the previous positions of multiple players.

var previousPosition:Vector3
# good

var prevPos:Vector3
# also good, but be careful as some abbreviations don't always un-abbreviate to your desired full word.
```

Static type your variables and always explicitly define the type of the variable.  This makes it slightly easier to understand the purpose of each function and variable.  It also helps Godot to tell you if you're using a variable wrong.
```gdscript
var myInt:int = 0
export var myModel:Node3D
var avoidDoingThis := asItCouldBe.unclearWhatTheResultingTypeIs()

# if the variable has to not be a single type (e.g a function parameter), then you can set the type to Variant
func someOther(variantVar:Variant) -> void:
```

If the variable is not supposed to be accessed outside of the script (e.g  a local counter variable), then prefix the variable with a `_`.  This has the added benefit of not appearing in the auto-generated documentation.
```gdscript
var _counter:int = 0
var _someList:Array = []
```

## Enums
Name both the enum using `PascalCase`, and its members using `UPPER_SNAKE_CASE`.
```gdscript
enum Modes {
	ATTACK,
	DEFEND,
	SPECIAL_ATTACK
}
```

## Constants
Same as variable, aside from the following.

Name using `UPPER_SNAKE_CASE`.
```gdscript
const SOME_KING_OF_CONSTANT:int = 1225
const _DIALOGUE_BOX_SCENE:Resource = preload("path/to/scene")
```

# Functions
Name using `camelCase`.
```gdscript
func thisIsCamelCase():
func ThisIsNotCamelCase():
func nor_is_this():
func OR_THIS():
```

Static type your functions and parameters as it'll make it slightly easier to tell what it's purpose is.  It also helps Godot to tell you if you're using a function wrong.
```gdscript
func doSomething(someVar:int) -> void:
```

If the function is not supposed to be accessed outside of the script (e.g  a function that spawns another node), then prefix the function with a `_`.  This has the added benefit of not appearing in the auto-generated documentation.
```gdscript
func _spawnDialogueBox(targetPos:Vector3) -> void:
```

Functions that are only ran when a signal is emitted should be prefixed with `_on_`, be named using `snake_case`, and should either call functions within the script, or call functions from the parameters.  Some exceptions, like the function being called to simulate the signal being emitted, or the code being hyper-specific to this signal emission, are fine.
```gdscript
func _on_some_node_fully_ready(theNode:SomeNode) -> void:
	moveSomeNode(theNode)
	theNode.playAnimation()
	someCounter += 1  # this is fine
	
	# this is not fine and should be moved to a new function
	theNode.color = Color.RED
	theNode.health -= Stats.attack
	if theNode.health < 0:
		theNode.health = 0
```

# Documenting Your Code
Refer to [this](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_documentation_comments.html) for creating proper documentation and for any optional fancy stuff you might want to put in.  Proper documentation will be used in Godot's built-in documentation thing.  If you've ever clicked the `Search Help` button in the top-right and searched for a node, it's that.  This type of documentation will also show up in a tooltip whenever you hover over a variable/function/member.

**Important**:  When making documentation for for anything that's only used in the script it lives in (i.e  stuff with a `_` prefix), make sure to put `[b]Internal-use only.[\b]` at the beginning.

While you can create documentation for function local variables, I'd recommend not doing so as it can lead to the code looking more "dense."  More dense code takes longer to parse.  Ideally, making the variable names descriptive will negate the need to write comments or documentation for function local variables.

# Test Scenes
Don't modify any existing test scene unless you're working on a feature that modifies the main thing it tests (e.g  modifying `DeathPlane` --> you can modify `test_death_plane.tscn`).

If a test scene has components that you need and already have setup, duplicate it and rename it according to the feature you're testing (e.g  explode NPCs area --> duplicate `test_npc_interaction.tscn` and name your duplicate `test_explode_npcs.tscn`)