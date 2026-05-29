# 1. Creating Models
When creating models for the game, whether it be for the environment or the [<img src="./icons/icon_interactable_NPC.svg"> Interactable NPCs](#interactable-npc), there a few things to keep in mind.

## 1-1. Rename Things
Rename any objects or materials you create in Blender.  It'll make things easier both in-engine and while modeling if things are named properly so you can easily reference them later.  There's no established naming scheme (e.g  Camel Case, Snake Case), so just name things so it's easy to tell what they are when reading them. 

## 1-2. Keep Textures With Models
It is recommend you keep texture files next to your model files, or keep them in the same relative path.
```
❌ Bad
--------------------------------
Desktop  
└── rusty-metal.png  
Documents  
└── test-environment.blend
--------------------------------

✅ Good
--------------------------------
models  
└── environment  
    ├── rusty-metal.png  
    └── test-environment.blend
--------------------------------

✅ Also Good
--------------------------------
models  
├── environment  
│   └── test-environment.blend  
└── textures  
    └── rusty-metal.png
--------------------------------
```
If you don't do this, while the texture may be able to load perfectly fine on your system, it may not when you share it with the rest of the team.  When sharing the file (either via GitHub or uploading via Discord), also share the texture files.

**NOTE:**  This may not be a problem if you export the model to a `glTF/glb` file, as Blender seems to pack the texture files with the model.  However, this can lead to duplicate texture files in the project, which unnececssarily increases filesize and will be annoying to fix later down the line.

## 1-3. Scale
When scaling your objects, make sure their scale doesn't go into the negatives, especially if the player is supposed to interact with them.  For whatever reason, if one or multiple of the axes are scaled negatively, the player will freeze in place and get softlocked.



# 2. Importing Models into Godot
Importing models into Godot is pretty easy as Godot automatically does the main stuff.  However, there arer a few things you should do so doing things with these models in Godot is easy.

## 2-1. All-In-One or Separate Parts?
There are two ways you could create a model.  One way is to keep all of your objects/shapes in one file (e.g  a player model).  Another is to create a separate file for each object/shape and import them into one "master" file (e.g  a common chair prop).  Both ways are valid, but if you choose to do the latter, do *not* assemble the parts in Godot if you plan on both adding collision and scaling them.  Refer to the "[Adding Collision](#adding-collision)" section for more details.  Additionally, keeping all modifications to a model to one place (i.e Blender) is better than having to keep track of what changes you've made at any possible point.
- e.g  you make a cube for your environment in Blender and make it 1 meter tall.  After checking on the cube in Godot, you are confused as to why it's now 0.75 meters tall.  It turns out you modified its scale in Godot and forgot about doing that.

### "How do I link an external model from a Blender file to a separate Blender file, while also telling the separate Blender file I made changes to the external model without having to re-import it?"
First, open the Blender file you want to import your external file into.  Next, drag and drop the Blender file with the external model into Blender.  You should get the following tooltip/pop-up.  Click the `Link` option.
<div align="center">
  <img src="./images/external-blender_1.png">
</div>

Next, enter the `Mesh` folder.  This holds all of the meshes in the Blender file you just drag and dropped.  Locate the external model you want to link and click the `Link` button in the bottom right corner of the file explorer pop-up window.
<div align="center">
  <img src="./images/external-blender_2.png">
</div>

Your external model is now in the separate Blender file.  You can move, rotate, and scale this model in this separate Blender file.  Updating the external model in its Blender file will be reflected in the separate Blender file.  *However*, it won't do this automatically.  There is an addon that adds this functionality (https://extensions.blender.org/add-ons/auto-reload/), but we haven't tested it.  Here's how to do it manually if the addon doesn't work:
1. Navigate to the Outliner/Object explorer in the top right and click the dropdown menu with the stacked images icon.  This is the `Display Mode` menu for the outliner.
<div align="center">
  <img src="./images/external-blender_3.png">
</div>

2. Open the dropdown menu and select `Blender File` (The normal display mode is `View Layer` by the way).  Next, locate an entry that contains the name of the Blender file with your external model and a link icon next to it.  This can either be found under the `Libraries` folder or at the bottom of the list.  Then right click the entry and select `Reload`.
<div align="center">
  <img src="./images/external-blender_4.png">
</div>

The changes you made to the model should now be visible.


#### "Why can't I use the object in the Object folder?"
You won't be able to move it for whatever reason.  Here's the official Blender documentation on it:  https://docs.blender.org/manual/en/latest/files/linked_libraries/link_append.html

#### "Why can't I just put the object into a collection and import the collection?"
While this will seem to work initally, when you get to generating the Occluder for the model in the "[Configuring the Model Import Settings](#2-3-configuring-model-import-settings)" section, the generated Occluder mesh for the model will be at the position the model is at in its source Blender file (usually 0,0,0).
<div align="center">
  <img src="./images/external-blender_collection.png">
</div>

If you don't care about this model being occluded though, I suppose it's fine to do this?  Ideally everything would have an occlusion mesh though.


## 2-2. Use `.blend` Files For Models
You don't have to export Blender files into a different format, as Godot can auto-import them without too much issue.  Additionally, any edits you save to the imported `.blend` file will automatically be re-imported into Godot without you having to redo the entire import process.  (There are some things you'll have to "redo" again but it's mainly for new stuff you add.  We''ll get to that).

Upon opening a `.blend` file in Godot, you should see something like the following pop-up window.  **Things may take a bit to import depending on the size of the model.**  This is usually because the model you're importing has a lot of things to import (e.g  a lot of vertices).  Don't worry though, just let it sit for a minute or two and Godot should finish loading everything.
<div align="center">
  <img src="./images/blender-file-popup.png">
</div>

**NOTE:** You may need to tell Godot when Blender is installed if Godot can't automatically find where Blender is installed.  You'll know if you have to if you see either of the following after trying to open a `.blend` file in Godot.
<div align="center">
  <img src="./images/open-blender-file_error_1.png">
</div>

<div align="center">
  <img src="./images/open-blender-file_error_2.png">
</div>

You can tell Godot where Blender is by going to (from the top left) `Editor > Editor Settings > FileSystem > Import > Blender > Blender Path` and adding the path to your local Blender executable there, including the actual executable.  In the Editor Settings panel, you can also search for "Blender" to more quickly find the appropriate setting subsection.
<div align="center">
  <img src="./images/blender-path_1.png">
</div>

<div align="center">
  <img src="./images/blender-path_2.png">
</div>

You can either paste the path into the text box or click the file icon next to the text field input and navigate to it from there.

### "My imported `.blend` models have no texture!"
This may be because you didn't also import the model's texture files along with the model.  This issue can be fixed by just moving the model's texture files to same relative location it expects them to be.  You do not have to re-import the model.

### "What if I have issues importing `.blend` files due to X?"
If there is an issue importing models using the `.blend` method:
1) Contact Ayden about the issue.  He should be able to assist with the process since he's been able to do this without issue for a couple of test models.  If you cannot get a hold of him, or you need to be able to import models *now*:
2) Export the model to a `glTF 2.0/glb` model.  This is the recommended file format for models you want to import into Godot.  (`.blend` is in second place due to theoretical workflows using older versions of Blender, and/or not all development-group workflows having everyone with Blender installed).  This will lead to duplicate texture files in the project, so keep that in mind if you decide not to fix your issue with `.blend` files not importing.

## 2-3. Configuring Model Import Settings
Your model is now in Godot!  Before you start using it though, there are some things we recommend you configure before continuing onward.

First, open the model file by double-clicking it in Godot.  This should bring up a pop-up that looks something like this:
<div align="center">
  <img src="./images/configure-model_1.png">
</div>

Now click on one of the `MeshInstance3D` nodes in the left panel.
<div align="center">
  <img src="./images/configure-model_2.png">
</div>

Go to the right panel, and under `Generate > Occluder`, set the value to `Mesh + Occluder`.  This will make it so the selected mesh won't render when it's not visible.
<div align="center">
  <img src="./images/configure-model_3.png">
</div>

Now, we recommend doing this with each `MeshInstance3D` node.  You can't multi-select and change this property on multiple nodes at once, so you have to do it one at a time.  However, this isn't mandatory (yet) as we don't have any performance concerns at the moment.  However however, we will probably have to do this later down the line at some point, so better to do it now than later.

Once configuration is complete, click the `Reimport` button.  You'll have to repeat this process for any new meshes you add, but it'll only be for the new mesh instance.  If you modify an existing mesh, Godot will automatically recalculate the occlusion mesh.