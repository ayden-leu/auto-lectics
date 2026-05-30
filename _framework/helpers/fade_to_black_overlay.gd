@icon("uid://cb6ajbh4fp7fh")
extends Control
class_name FadeToBlackOverlay
## A helper scene that creates a fade-to-black screen transition. 
## 
## Can be used for scene transitions, player respawning, 
## cutscenes, dialogue sequences, or any situation where the screen 
## should fade in or out. 
## [br][br] 
## To use, add the pre-built [FadeToBlackOverlay] scene to your scene. 
## Then call [method startFadeIn] or [method startFadeOut] 
## whenever a fade transition is needed. 
## [br][br] 
## The [signal fade_in_complete] and [signal fade_out_complete] 
## signals can be used to perform actions once the transition 
## animation has finished. 
## [br][br] 
## The animation is entirely controlled by the attached 
## [class AnimationPlayer]. 
## Modify the fade animations there if a different transition speed 
## or appearance is desired.

# ------------------------------------------------
# signals
# ------------------------------------------------
## Emitted when the overlay fades in fully.
signal fade_in_complete()
## Emitted when the overlay fades out fully.
signal fade_out_complete()

# ------------------------------------------------
# enums
# ------------------------------------------------

# ------------------------------------------------
# constants
# ------------------------------------------------

# ------------------------------------------------
# export variables
# ------------------------------------------------

# ------------------------------------------------
# onready variables
# ------------------------------------------------
## [b]Internal-use only.[/b]  The animation player that plays the fade animations.
@onready var _animPlayer:AnimationPlayer = %AnimationPlayer

# ------------------------------------------------
# normal variables referenced outside of script
# ------------------------------------------------

# ------------------------------------------------
# normal variables only referenced in script
# [b]Internal-use only.[/b]
# ------------------------------------------------

# ------------------------------------------------
# functions like _ready, _process, and _physics_process
# ------------------------------------------------

# ------------------------------------------------
# functions referenced outside of this script
# ------------------------------------------------
## Starts the fade-in animation.
func startFadeIn() -> void:
	_animPlayer.play("fade_in")

## Starts the fade-out animation.
func startFadeOut() -> void:
	_animPlayer.play("fade_out")

## Resets the overlay, which makes it invisible.
func reset() -> void:
	_animPlayer.play("RESET")

# ------------------------------------------------
# functions only referenced inside this script
# [b]Internal-use only.[/b]
# ------------------------------------------------
## [b]Internal-use only.[/b]  Ran by the animation player.
## Runs when the fade in animation is complete.
func _fadeInComplete() -> void:
	fade_in_complete.emit()

## [b]Internal-use only.[/b]  Ran by the animation player.
## Runs when the fade out animation is complete.
func _fadeOutComplete() -> void:
	fade_out_complete.emit()

# ------------------------------------------------
# functions that run when a signal is emitted
# ------------------------------------------------

# ------------------------------------------------
# editor dev-ing functions like "_get_configuration_warnings()"
# ------------------------------------------------
