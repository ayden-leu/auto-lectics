# 4. Proper Node Setup
This contains the proper node setup for each node, as well as any other general notes for other built-in Godot nodes.

## 4-1. Generally
Built-in Godot nodes and some nodes created by us may have a ⚠️ warning sign appear next to them.  This is because some property of the node isn't configured properly.  If you hover over the ⚠️ warning sign, a tooltip should appear explaining what needs to be done to make them go away.  For some warnings, you'll need to save the scene before it detects your changes.  Also, some improperly configured aspects won't warn you when they're not set.  For built-in Godot nodes, this is (usually) because there's no way for the node to detect it.  For nodes created by us, it may be due to an oversight or not *technically* being needed.

## 4-2. Creating/Adding a Node
There are three methods for creating/adding one of our custom nodes to a scene.  It is important you choose the right method as some nodes have needed children, which won't be added if you choose the wrong method.  The correct method to do so for each node will be noted in that node's subsection in the "[Nodes Created By Us](#4-5-nodes-created-by-us)" section.

### Root
This method is for when you're making one of our nodes the root node of a scene.  You'll want to do this if you're using one of our nodes as a base and customizing it (e.g  making a new NPC).

First, create an empty scene by clicking the `+` button located around the top of the middle area under the view switching area.
<div align="center">
  <img src="./images/creating-root-scene_1.png">
</div>

This should create a new tab named `[empty]`.  Next, in the left panel, click the `Other Node` button.  This will create a pop-up window that lists all of the built-in Godot nodes along with our custom nodes.
<div align="center">
  <img src="./images/creating-node_1.png">
</div>
<div align="center">
  <img src="./images/creating-node_2.png">
</div>

You can search for a node by clicking the search area, then typing.  The search area should be auto-selected when the pop-up window appears.  Once you find your node, click the `Create` button, double click the node, or press the `Enter` key.

### Create Child
This method is mainly used for nodes that don't have pre-configured children nodes.  Nodes that use this adding method can also be added with the [Instantiate Scene](#instantiate-scene) method.  This method is also how you add built-in Godot nodes.

Under the scene tab on the left panel, click the `+` button or right-click the node layout area and choose `Add Child Node...`.  This will create a pop-up window that lists all of the built-in Godot nodes along with our custom nodes.
<div align="center">
  <img src="./images/creating-child-node_1.png">
</div>
<div align="center">
  <img src="./images/creating-node_2.png">
</div>

You can search for a node by clicking the search area, then typing.  The search area should be auto-selected when the pop-up window appears.  Once you find your node, click the `Create` button, double click the node, or press the `Enter` key.

### Instantiate Scene
This method is mainly used when a node has pre-configured nodes setup in its scene file.  You can also use this method to add nodes that use the [Create Child](#create-child) method.

In the FileSystem, you can either search through the folders for the Scene you want to add, or you can search for them using the `Filter Files` search box.  Scenes are denoted by the `.tscn` extension.  Once you find your node/scene, drag and drop it onto a node in the `Scene` tab.
<div align="center">
  <img src="./images/creating-child-node_2.png">
</div>

Alternatively, you can right-click the node layout area and choose `Instantiate Child Scene...`.  This will create a pop-up window that lists all `.tscn` files in the project.
<div align="center">
  <img src="./images/creating-instantiate-node_1.png">
</div>
<div align="center">
  <img src="./images/creating-instantiate-node_2.png">
</div>


## 4-3. Naming a Node
Like with [Blender object names](#1-1-rename-things), you should give any node you add to a scene a proper name.  Sometimes, this isn't needed as the generic name is descriptive enough (e.g  a `CollisionShape3D` for an `Area3D`).  Other times, you should rename it to better convey its purpose (e.g  renaming an `Area3D` to "Hitbox" to convey that it is a hitbox).  Leaving everything with their default names won't break anything, but it'll make debugging take a bit longer.