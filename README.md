# AUTO-Lectics
The main development repository for the AUTO-Lectics game.

Engine:  Godot v4.5.1

**Relevant links:**
- Main game page:  https://meep-marcelle.itch.io/auto-lectics-demo
- Documentation main page:  [_documentation/main_page.md](_documentation/_main_page.md)



## Index
1. [Repository Structure](#repository-structure)
	1. [`main_framework`](#main_framework)
	1. [`main_designers`](#main_designers)
	1. [`main_intermediate`](#main_intermediate)
1. [Downloading and Opening the Project](#downloading-and-opening-the-project)
1. [Navigating the Project](#navigating-the-project)
	1. [Project Folder Structure](#project-folder-structure-main_framework)
	1. [_framework Folder Structure](#_framework-folder-structure)
1. [Contributing](#contributing)
1. [Credits & Attributions](#credits--attributions)



## Repository Structure
There are two (sometimes three) main development branches.

### main_framework
This branch is where all of the custom components are developed.

All components in this branch are considered "stable."  Development of new features or tweaks to existing features are done in separate branches, which are eventually merged into this one upon verification.

Documentation of all custom components and features can be found in [the documentation main page.](_documentation/_main_page.md)

### main_designers
This branch is where all of the actual game content is created and stored.

This branch is typically "behind" in features compared to `main_framework` due to new/tweaked components potentially affecting existing game content.  When this branch needs to be up-to-date in features, the `main_intermediate` branch gets created and a pull request is made.

### main_intermediate
This branch is a copy of `main_designers` and doesn't always exist.

The branch gets made whenever new components from `main_framework` are wanted in `main_designers`.  This branch is neccesary as new/tweaks components can potentially affect existing game content, requiring manual fixes to ensure no regressions.



## Downloading and Opening the Project
1. Download the source files.
1. Open `project.godot` in Godot v4.5.1
1. Import and open the project in the project manager.



## Navigating the Project
### Project Folder Structure (main_framework)
1. `_documentation`:  Holds documentation for the custom components, as well as other helpful development information.
1. `_framework`:  Holds all custom components.  These files generally shouldn't need to be modified outside of development unless a visual aspect needs to be modified.
	- See [this section](#_framework-folder-structure) for a breakdown of this folder's folder structure.
1. `dialogue_objects`: Holds all dialogue trees for the game.
	- Refer to [the dialogue documentation](_documentation/framework_guides/dialogue.md) for further explanation.
1. `fonts`:  Holds all text fonts used for the game.
	1. `_label_presets`:  Holds all Label Presets used for the game.
1. `script_templates`:  Holds custom script templates for various node classes.  Mainly used to aid in development.
1. `sounds`:  Holds all sound files used in the game.
	1. `sfx`:  Holds all SFX IDs used in the game.
		- Refer to [the audio loader system](_documentation/framework_guides/helpers/audio_loader.md) for further explanation.

### _framework Folder Structure
1. `_visual_assets`:  Holds resource files for all of the visual aspects of the custom components.
	- NOTE:  Some visual aspects cannot be saved to an external resource, so not everything is located in here.  Said some are usually located in the relevant scenes themselves.
1. `dialogue_creator`:  Holds everything related to the DialogueCreator tool.
	- NOTE:  This may be moved in the future in order to integrate it into the editor itself.
1. `dialogue_visuals`:  Holds all components related to displaying dialogue trees and text.
1. `editor_files`:  Holds custom things related to the Godot editor.  (Just custom icons at the moment.)
1. `entities`:  Custom entity-related components created for the game.
	1. `npcs`:  NPC-related components.
	1. `player`:  Player character related components.
1. `helpers`:  Smaller custom components and features that can be used by the designers.
1. `test_scenes`:  Scenes that test each custom component.
1. `ui`:  Holds everything related to the User Interface.
	1. `hud`:  Holds everything related to the in-game HUD.
	1. `menus`:  Holds everything related to menus the player can navigate.



## Contributing
This is mainly for the team working on this game since this isn't a public repository at the moment.

1. Create a new branch and develop your new Thing in it.
1. If your new Thing is supposed to go into `main_framework`:
	1. Refer to [the style guide](_documentation/style_guide.md) for how to properly format your code.
	1. Create a new Pull Request and describe what your new feature is.  Be sure to include documentation on how to use it and what it does!
	1. Ayden will then review it before merging.
1. Otherwise (i.e it's going into `main_designers`), you can just merge it as it since it'll most likely not have any merge conflicts*.
	- *unless you and someone else are modifying the same thing, in which case there will be one.



## Credits & Attributions
`InputHandler` icon:  https://www.freepik.com/free-vector/game-controller-simple-detailed-line-flat_423530024.htm
