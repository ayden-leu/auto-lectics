## Developing Notes
- Collision layers exist.  They can be configured under `CollisionObject3D > Collision`
	- `Layer` holds the collision layers the physics body is on.
	- `Mask` holds the collision layers the physics body interacts with.
		- e.g  The ground does not interact with the player.  The player interacts with the ground.
- RayCast3D can be configured to interact with Areas and Bodies.  It doesn't interact with Areas by default.
- Area3D can be set to Monitoring and Monitorable.  Monitoring means it can detect when something enters its area.  Monitorable means other things can detect when it enters their area.
- If you need to access the children of an inherited scene, right click it and enable `Editable Children` near the bottom half of the menu.

## 4-4. Built-in Godot Nodes
### Area3D/StaticBody3D & CollisionShape3D
`StaticBody3D` is the main node type of a non-moving "solid" object and is usually used for the environment.  `Area3D` is the main node type for creating areas that will interact with each other for other, non-collision reasons (e.g  an interaction hitbox).  `CollisionShape3D` is a general-purpose collision node that handles the shape of collision-related nodes.

Scaling a `StaticBody3D` or `CollisionShape3D` un-uniformly (i.e not the same amount for each axis) will cause a ⚠️ warning sign to appear.  This is because scaling either of them this way can make collision go wonky.  Based on sparse testing, scaling the parent node should be fine.

To modify the size of a collision shape properly, modify the properties of the `CollisionShape3D`'s shape.
<div align="center">
  <img src="./images/collision-shape-3d_shape.png">
</div>