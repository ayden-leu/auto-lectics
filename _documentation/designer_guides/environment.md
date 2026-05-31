# 3. Setting up the World.
While you can just add nodes to the scene willy-nilly after copy-pasting an already setup world, you should really learn how to setup one of these worlds from scratch to understand what parts are important.

An example world setup can be found in `_documentation/examples/environment-setup`.

## 3-1. Adding Collision to the Environment
Please refer to "[Importing Models into Godot](#2-importing-models-into-godot)" for importing the environment model into Godot.  This section is for setting up the collision for an environment.

First, drag the model file from the `FileSystem` tab into the main viewport.  This will place the model into the world.
<div align="center">
  <img src="./images/using-model_1.png">
</div>

Next, click the Movie Clipboard Icon next to the eye to open the model in the editor.  When asked to confirm, click `New Inherited`.  Clicking `Open Anyway` won't let us save any changes we make to the model through Godot.
<div align="center">
  <img src="./images/using-model_2.png">
</div>

A new tab named `[unsaved](*)` should be opened with our model visible.  Any changes made to the model file will made reflected here.  You will not be able to modify any model objects in Godot.  This is ***NOT*** the scene where we put our player character or NPCs.  This is purely for the model of the world.  Be sure to save this new inherited scene into the `world` folder and name it something relevant.  For these screenshots going forward, it'll be named `test-environment_model`.
<div align="center">
  <img src="./images/using-model_3.png">
</div>

With our new inherited scene, we can now add collision.  Select the `MeshInstance3D` nodes you want to add collision to.  You can select multiple at once.  You don't have to do all of them at once; you can do chunks at a time.

Once all meshes are selected, navigate to the top toolbar, click the `Mesh` dropdown button with the `MeshInstance3D` icon, then click `Create Collision Shape...`
<div align="center">
  <img src="./images/using-model_4.png">
</div>

You'll be presented with two options: one for how to create the collision nodes, and one for how the shape should be generated.  Set `Colllision Shape Placement` to `Static Body Child` and set `Collision Shape Type` to `Trimesh`.  There are hover tooltips for each option that describe what they do.
<div align="center">
  <img src="./images/using-model_5.png">
</div>

Now, select each `StaticBody3D` that was generated.  You can select multiple at a time.  Then, go to the panel on the right and expand the `Collision` section.  Under `Layer`, enable Bit 2/Square 2/Environment and disable the rest of the bits/squares.  This tells Godot that anything that is supposed to collide with the environment is also supposed to collide with this.  Under `Mask`, disable all bits/squares.  This tells Godot that this `StaticBody3D` is not on the lookout for anything that is colliding with it.
<div align="center">
  <img src="./images/using-model_6.png">
</div>

Remember to save your changes.

With collision setup, go back to your main world scene.  Select and delete the model you drag and dropped into the world, as this is not the new inherited scene we just finished creating.
<div align="center">
  <img src="./images/using-model_7.png">
</div>

Now drag and drop the scene we setup the collision in onto the main viewport.  For these screenshots, it's `test-environment_model.tscn`.
<div align="center">
  <img src="./images/using-model_8.png">
</div>

Also make sure its position is set to the origin of the scene (`0, 0, 0`).  Nothing will break if you don't do this, but it's nice to have the origin of the model be in the same place as the origin of the scene.
<div align="center">
  <img src="./images/using-model_9.png">
</div>

Your environment model with collisions should now be in the world!  Any changes you save to the environment model file should automatically be reflected in Godot when you make Godot focused (i.e click the Godot window).

### "Do I have to go through the whole collision generating process again whenever I update the model?"
No and yes.  If you only make a change to a single object's mesh, you won't have to generate collisions for the other objects you didn't modify.  However, for each object mesh you modifed, you will have to regenerate their collision.

You ***do not*** have to make a new inherited scene.  You'll just need to regenerate the collision shapes.


## 3-2. Other Visuals
Currently, there is only one other node needed to make the environment not look blank.  The view we get in the main viewport is not the world we see once we hit play.
<div align="center">
  <img src="./images/other-visuals_1.png">
</div>
<div align="center">
  <img src="./images/other-visuals_2.png">
</div>

To fix this, add a `WorldEnvironment` node.  When you do, the main viewport's background will turn gray like it is in-game.  This doesn't look good though, so load the default environment resource (`default_environment.tres`) into the Environment property of the `WorldEnvironment` node by selecting the `WorldEnvironment` node, locating `default_environment.tres` in the `FileSystem`, and dragging and dropping it.
<div align="center">
  <img src="./images/other-visuals_3.png">
</div>

The world should look not-gray now.  As of writing, the world should look the same as it did during the Week 6 playtest.  I'm not too sure what each property of the environment resource does, so play around with them!  You can always reset them to their default value by clicking the reset/redo icon next to the property.


## 3-3. Letting the Player Explore the Environment.
To let the player actually explore this environment, there are two scenes you need to add:

1. `player.tscn`:  Located in `entites > player`
	- The initial position you put this player scene will be the position the player is at when this environment scene is loaded.
2. `player_camera.tscn`:  Located in `entities > player`
	- Unlike `player.tscn`, you don't have to move this anywhere.

Remember to read the "[Proper Node Setup](#4-proper-node-setup)" section to properly setup these nodes.

That's it!  Players will be able to explore this environment when the scene is loaded.  To test it out, press the `Run Current Scene` button in the top right, or press `F6`.
<div align="center">
  <img src="./images/testing-scene_1.png">
</div>