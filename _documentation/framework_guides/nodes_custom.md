## 4-5. Nodes Created By Us
### NOTE: Extending Functionality
If you want to create additional code for one of our custom nodes (e.g  changing its rotation every frame), you'll want to extend its script.  To do this, first select the node you want to extend its script from.  Then, click the button that looks llike a scroll with an arrow on it.  This will create a pop-up window for attaching a script to this node.
<div align="center">
  <img src="./images/extend-script_1.png">
</div>
<div align="center">
  <img src="./images/extend-script_2.png">
</div>

Next, make sure to set a proper name and save location for the script you're about to create.  For example, if you're creating a new [<img src="./icons/icon_NPC.svg"> NPC](#npc), save the script to `entities/npcs/` and name it the same name as your <img src="./icons/icon_NPC.svg"> NPC.  **Make sure you don't overwrite any existing files you don't want to overwrite**.  We'll be able to revert files that are backed up on the GitHub repository, but most likely won't be able to for other files.




### <img src="./icons/icon_input-handler.svg"> InputHandler 
- **Corresponding scene file**: `helpers/input_handler.tscn`
- **Adding Method**:  [Create Child](#create-child)

Handles all potential inputs a player can make.  Should only be used if you need to know when a certain player input happens.  Otherwise, they will automatically setup by us when needed (e.g  [Player](#player) already comes with one).

To properly use an InputHandler, select it then go to the right panel.  Select the `Node` tab and enter the `Signals` tab if it isn't already selected.  You should now see `InputHandler`'s signals.

There are 4 signals the InputHandler emits:
1. `interact_button_pressed()`:
  - Emits when the interact button is pressed.
2. `jump_pressed()`:
  - Emits when the jump button is pressed.
3. `mouse_moved(distanceMoved: Vector2)`:
  - Emits when the mouse is moved.
  - `distanceMoved` is a `Vector2` that contains the `x` and `y` distance the mouse moved in this frame.
4. `update_input_direction(newDirection: Vector2)`:
  - Emits constantly to update the input direct the player is holding.
  - `newDirection` is a `Vector2` that contains a normalized version of the player's currently held input direction for this frame
    - e.g  holding right = `(1.0, 0.0)`
    - e.g  holding up = `(0.0, -1.0)`
    - e.g  holding up and right = `(sqrt(2), -sqrt(2))`

To connect a signal, select it and click the `Connect` button at the bottom of the panel.  This will open a node selection pop-up.  Now, pick the node you want to connect the signal to and click the `Connect` button.  This will automatically create a new function in your target node's script.

If you already have a function prepared, select the `Pick` button after selecting your target node.  This will open a new pop-up with all of the eligible functions in your target node's script.  If you don't see your function, make sure the types of its parameters are the same as the signal's.

### Player
- **Corresponding scene file**: `entities/player/player.tscn`
- **Adding Method**:  [Instantiate Scene](#instantiate-scene)

The main node that gets controlled by the player.  It currently needs no additional setup.  You can also mess around with its movement parameters if you'd like.

### Player Camera
- **Corresponding scene file**: `entities/player/player_camera.tscn`
- **Adding Method**:  [Instantiate Scene](#instantiate-scene)

Holds both the player's camera and the HUD node.  It has one required property: `Focus`.  `Focus` should be set to the main object that the player should see a first-person perspective from (e.g  [Player](#player)).

Might be switched to a Camera3D node if time allows for us to relook at the camera setup.

TODO:  verify this is still valid with the fixed camera bug.

### <img src="./icons/icon_NPC.svg"> NPC
- **Corresponding scene file**:  `None`
- **Adding Method**:  [Root](#root) if creating a new NPC, [Instantiate Scene](#instantiate-scene) if adding a pre-made NPC.

Requirements:
1. A model.
  - Please see section "[Importing Models into Godot](#2-importing-models-into-godot)" for how to properly import models into Godot.
  - Not used for anything currently, but may be used in nodes, classes, or scripts that extend this type of node (e.g  [<img src="./icons/icon_interactable_NPC.svg"> Interactable NPC](#interactable-npc))
2. A name.
  - This is different from naming this node in the current scene, as you can theorhetically have multiple copies in the same scene.  Currently, this parameter isn't for anything, but it may be used in nodes, classes, or scripts that extend this type of node (e.g  [<img src="./icons/icon_interactable_NPC.svg"> Interactable NPC](#interactable-npc))

A basic NPC that just exists in the world.  Currently, it doesn't do much.

TODO:  explain idle path navigation when that gets implemented.

### <img src="./icons/icon_interactable_NPC.svg"> Interactable NPC
- **Corresponding scene file**:  `None`
- **Adding Method**:  [Root](#root) if creating a new Interactable NPC, [Instantiate Scene](#instantiate-scene) if adding a pre-made NPC.
- **Inherits**:  [<img src="./icons/icon_NPC.svg"> NPC](#npc)
- **Example Setup**: `_documentation/examples/npc-setup`

An NPC that can be interacted with to begin a conversation.  If you do not plan on giving a NPC a dialogue interaction, please create an NPC instead.  All notes and aspects that apply to [<img src="./icons/icon_NPC.svg"> NPC](#npc) also apply to [<img src="./icons/icon_interactable_NPC.svg"> Interactable NPC](#interactable-npc).

Requirements:
1. Everything from [<img src="./icons/icon_NPC.svg"> NPC](#npc).
2. A hitbox.
  - A hitbox is an `Area3D` node with a `CollisionShape3D` child node.  The `CollisionShape3D` node controls the shape and the `Area3D` controls the configurations.
  - Make sure the `Area3D`'s collision layers are setup correctly.  You can configure these layers under the `Collision` tab on the right.  For [<img src="./icons/icon_interactable_NPC.svg"> Interactable NPCs](#interactable-npc), they require the 3rd bit of the `Layer` aspect to be set, and only that bit.  All bits under `Mask` shouldn't be set, but nothing will break if you forget to change them.
  - <img src="./images/creating-interactable-npc_1.png">
3. A dialogue box anchor.
  - This anchor is a `Marker3D` node and controls where the Dialogue Box spawns when a dialogue event happens.
  - There are two ways you can add this:
    1. As a child of this or a different node.  Doing it this way will make the Dialogue Box follow and rotate with the its parent.
    - <img src="./images/dialogue-anchor_1.png">

    2. As a child of a Node(basic).  This will make the Dialogue Box not move or rotate with any node.
    - <img src="./images/dialogue-anchor_2.png">

  - **Important:** If you choose option 2, the anchor's position will be relative to world space instead of local space.  What this means in practice is that it's position will be based around the origin of the environment instead of whichever parent node.
  - <img src="./images/dialogue-anchor_3.png">
  - <img src="./images/dialogue-anchor_4.png">
4. Initial dialogue ID
  - The initial dialogue object the dialogue event will use when the player interacts with this.
  - Valid dialogue objects are located in `dialogue_objects/[NPC name]/`.
