extends Node3D

@export var path : Path2D
@export var curveHere : Curve   

var curveProgress = 0

var spotEnergy = 7.645
var omniEnergy = 1.0

var flickering = false

func _ready() -> void:
	FR_MenuManager.disable() # either enable() or disable()
	FR_WindowManager.disable() # either enable() or disable()
	CursorHandler.setDefault("hidden") # refer to documentation or hover over the function for valid values
	CursorHandler.hideNuclear() # either hideNuclear() or showNuclear()

# don't forget that _process() and _physics_process() exist.
# they'll show up on the auto-complete.

func _flicker() -> void: 
	flickering = true
	
func _stopFlicker() -> void: 
	flickering = false
	spotEnergy = 7.645
	omniEnergy = 1.0
	curveProgress = 0
	
func _process(delta: float) -> void:
	#print(flickering)
	if flickering == true: 
		#print("flickering")
		#print(curveHere.sample(curveProgress))
		#print(curveProgress)
		#print($SpotLight3D.light_energy * curveHere.sample(curveProgress))
		$SpotLight3D.light_energy = $SpotLight3D.light_energy * curveHere.sample(curveProgress)
		$SpotLight3D/OmniLight3D.light_energy = $SpotLight3D/OmniLight3D.light_energy * curveHere.sample(curveProgress)
		curveProgress = curveProgress + 0.00001
	
	
	
