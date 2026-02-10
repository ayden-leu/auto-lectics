# AUTO-Lectics
Main repository for the AUTO-Lectics game.

Engine:  Godot

---

# Project Structure
1. `globals.gd`:
	- Holds global variables.
	- Should only contain information needed everywhere in the game
		- Example:  Paths to scenes so we can easily create them.
2. `addons`:
	- Main folder for any third-party addons we use.
3. `dialogue_objects`:
	- Holds all of the dialogue objects and configurations.
	- Also holds the translated text until we add non-english language support.
4. `dialogue_visuals`:
	- Holds files related to the in-world dialogue stuff.
5. `entites`:
	- Holds files related to any Being in the game (The player, NPCs)
6. `helpers`:
	- Holds files related to resources that manage other resources.
	- e.g  Input handler
7. `language_files`:
	- Holds the language files that'll be swappable in-game.
	- Not used for now.
8. `materials`:
	- Holds all shader material presets.
9. `models`:
	- Holds all models, their associated textures, and auto-generated scenes Godot makes when you try editing them in-engine.
	- Ideally, all models should be `.blend` files since you can easily see any changes made to them in Blender.
10. `shaders`:
	- Holds all `.gdshader` files.
11. `sounds`:
	- Holds all of the sounds for the game.
12. `test_scenes`:
	- Holds files meant for developers to test stuff.
	- These files should not be used in the final game.
13. `textures`:
	- Holds all textures not related to a model.
14. `ui`:
	- Holds files related to non-diagetic things the player interacts with.
	- e.g  Main menu, HUD, settings
15. `world`:
	- Holds the actual scenes/levels that will be used in the final game.

## Developing Notes
- Collision layers exist.  They can be configured under `CollisionObject3D > Collision`
	- `Layer` holds the collision layers the physics body is on.
	- `Mask` holds the collision layers the physics body interacts with.
		- e.g  The ground does not interact with the player.  The player interacts with the ground.
- RayCast3D can be configured to interact with Areas and Bodies.  It doesn't interact with Areas by default.
- Area3D can be set to Monitoring and Monitorable.  Monitoring means it can detect when something enters its area.  Monitorable means other things can detect when it enters their area.
- If you need to access the children of an inherited scene, right click it and enable `Editable Children` near the bottom half of the menu.

---

# Notes for Designers
(this will be moved somewhere more appropriate later)
This section details the functionality we plan to add by the end.  Some aspects may not be implemented yet.

# Adding Dialogue
In `dialogue_objects`, each NPC gets its own folder that matches its name, which is the name of the root node of its scene.
The name of the `.json` file is important, as that will be its ID.
```
dialogue_objects
├── NPC_Test
│   ├── Dialogue1.json
│   ├── Dialogue2.json
│   ├── Dialogue3.json
│   └── Dialogue4.json
└── John
    ├── FirstMeeting.json
    ├── WithCake.json
    ├── Injured.json
    └── Injured_2.json
```

## Fields required for a dialogue entry:
- `text`: The text that appears in the main dialogue box.
- `type`: The type of dialogue it is.
	- Neutral
	- Happy
	- Angry
	- Confused
	- Sad
- `mode`: The dialogue mode.
	- Normal
	- Hectic
- `nextOnHecticFailureID`: The ID of the next dialogue entry to load upon failing hectic mode.
	- If this dialogue's mode isn't in hectic mode, you can keep it blank.
- `options`: A list of options the player can pick from.
	- `text`: The text that appears in the main dialogue box.
	- `type`: Whether this option is a good choice or not.
		- Positive
		- Neutral
		- Negative
	- `nextID`: The ID of the next dialogue entry.
		- If this is empty, the dialogue will end when the player selects this dialogue.

There are other optional fields you can fill out to customimze the dialogue.
`Dialogue1a.json` has all posssible fields written out, and `Dialogue1b.json` is a minimal version of it.
The game will automatically fill in the missing fields.

Some fields may not be implemented or customizable yet.  These include:
- Option `lifetime`
- `particles`
- `sfx:spawn`
- `backgroundTheme`
- `font`

---

# Connecting to the GitHub Repository
This section will help you setup a git management tool so you can push and pull changes to and from the repository.
## Step 1:  Setup an SSH key for your GitHub account
GitHub has deprecated the easier method of using a username and password to login to git in some cases.  I am not aware if this change applies *everywhere*, but I believe it is best to assume so.  Also, using an SSH method *is* more secure even if there is more setup involved.
1. Go to your GitHub account settings.
	- Found by going to User Profile Icon in Top Right on GitHub > Settings
	- or click this link:  https://github.com/settings
2. Go to the `SSH and GPG keys` tab on the left.
3. Follow the official guide for generating a new SSH key.
	- Link:  https://docs.github.com/en/ahuduthentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
4. Follow the official guide for adding a new SSH key to your GitHub account.
	- Link:  https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
5. Follow the official guide for testing your SSH connection.
	- This is technically optional, *but* I recommend doing this just in case a future step goes wrong.
	- Link:  https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection

## Step 2:  Cloning the GitHub Repository
This step assumes you have Git installed.  Please install Git if you do not have it.
1. Click the green button that's labeled `\<> Code`
2. Click the `SSH` tab and copy the text within.
	- Should look like `git@github.com:ayden-leu/auto-lectics.git`
3. On your computer, navigate to where you want to store the repository files, and open a terminal/command prompt.
4. Run `git clone <the text you copied previously>`
	- If you get an error saying `Please make sure you have the correct access rights`, then it is possible your SSH key is not added to your SSH agent.  If so, follow the official guide for adding your SSH key to the SSH agent.  Try running the command again once this is complete.
		- Link:  https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent
5. Verify that you can open the project in Godot
	- We are using Godot v4.5.1

# TL;DR for Submitting Changes
***Please*** follow this methodology so we don't run into complicated merge conflicts down the line.

1. Make sure you are ***not*** on the main branch before you start making changes.  The specifics for finding out which branch you're on depends on your method.
2. Make a commit every time you change something so progress is saved.  Your commit message should be a good summary of the changes you have made up to that point.  Smaller commits can make the process of fixing an unknown issue easier.
3. When you are ready to submit your changes to main, push all of your commits to your branch on the repository, then make a Pull Request.
	- To make a pull request, there will be a noticable green buttom that says "Pull Request."  If not, then click the `Contribute` button and click `Open pull request`.
	- Be descriptive about your changes when writing the pull request title and description.  It'll help the team understand all of your changes.
4. *Do Not Merge Your Pull Request Immediately*.  Wait for another team member to approve of the merge.
	- This will allow the team to read your code and raise any issues they have with your implementation.  These issues can range from self-documentation being unclear to additional or missing features they would like to be implemented.
	- Also, the merge might cause some merge conflicts since merge conflicts are bound to happen.  Sorting this out *before* the merge happens will be ideal.
	- If you are the one to merge the pull request, please copy-paste the original pull request's description into the extended description box.
5. Delete your branch.
	- Once the changes are merged, your branch won’t serve a purpose anymore.  It's recommend you do this even if you decide to immediately work on a new feature as the main branch may have been updated with other changes.

# Committing Changes to the GitHub Repository
There are a handful of ways to push and pull commits to and from the repository.  This section is mainly for describing how to use the Godot Git Plugin as setting it up can be a bit weird.  *It is important that you follow these steps before making changes.*

First, configure your name and email in git for this project.
1. Open a terminal/command prompt in this project's directory.
2. Run `git config user.name <your GitHub account username>`
3. Run `git config user.email <your GitHub account email>` 

Then, pick a one of the following methods of your choice.

### Method 1:  Godot Git Plugin
The Godot Git Plugin addon will already be installed when you clone the repository.  This section will help you set things up so you can make and push commits to the repository within Godot itself.
1. Go to `Project > Version Control > Version Control Settings`
2. Set the VCS Provider to `GitPlugin`
	- It's the only option there but check just in case.
3. Enable `Connect to VCS`
4. Fill out the following fields under `Remote Login`
	- Username:
		- Your GitHub username
	- Password:
		- Keep blank as we're using the SSH method
	- SSH Public Key Path:
		- Click the red file icon and locate the public key file you created during [Connecting to the GitHub Repository](#connecting-to-the-github-repository).  The public key file has a file extension of `.pub`
	- SSH Private Key Path:
		- Click the red file icon and locate the private key file you created during [Connecting to the GitHub Repository](#connecting-to-the-github-repository).  This file should be located next to your public key.
		- Don't worry about these files being uploaded to the repository.  They won't be uploaded.
	- SSH Passphrase:
		- The password you set when making your SSH key during [Connecting to the GitHub Repository](#connecting-to-the-github-repository).  If you didn't set one, then leave this blank.
		- **Important:**  If you did set a password, you will have to re-enter it every time you open this Godot project.
5. Apply your configuration by clicking the `Apply` button.
6. Expand the right panel in Godot by hovering over the border between it and the main viewport, and click-dragging to the left.
7. Enter the `Commit` tab, which is in the same area as the `Inspector` tab.
8. *Verify you are not on the main branch*
	- You can find which branch you're on by looking at the left dropdown menu below the `Commit List` box, which is below the `Commit Message` box.  This is the branch dropdown menu.
	- If you are on the main branch, either switch to your branch or create a new one.
		- If your branch is on the GitHub repository and you cannot find it in the branch selection dropdown menu, follow the steps to create a new branch.  Don't worry, it won't make a duplicate branch on the GitHub repository.
	- Creating a new branch:
		1. Make sure you are in the `Commit` panel on the right.
		2. Click the three dots on the right side of the panel.
		3. Select `Create New Branch`
		4. In the pop-up enter the name of your new branch.
			- Name the branch based on the feature you’re developing so it is clear what the purpose of the branch is.
			- Your new branch will be auto-selected.
			- You can verify this by checking if the branch selection dropdown menu has the name of your branch.
	- To be safe, fetch your branch by clicking the button that looks like a reload symbol.  Then pull your branch by clicking the button next to it, which will look like a down arrow with a line above it.
9. Make any changes you want to make.
	- Make sure not to make too many changes per commit though, as you may accidentally break something and not know how to fix it.  Having a working commit from not too long ago can make the process of fixing it easier.
10. Stage your changes by either double-clicking a change or clicking the `Stage all changes` button in the top right of the `Unstaged Changes` area.  It looks like a down arrow with a line at the top.
11. Enter your commit message in the `Commit Message` box
	- This can be found below the `Staged Changes` box, which is located under the `Unstaged Changes` box.
	- Your commit message should be a good summary of the changes you have made up to that point.
	- If you get an error in the Output tab that says `Signature cannot have an empty name or email`, you need to configure your name and email for this project.  Instructions can be found [at the very top of this section](#committing-changes-to-the-github-repository).
	- **Important:**  Make sure you're not on the main branch!
12. Click the `Commit Changes` button.
13. Click the `Push` button, which is on the bottom and looks like an up arrow with a line below it.
	- Godot might freeze up for a while when you do this.  This may be due to your SSH Passphrase not being set in the Version Control Settings.  Force-close Godot, reopen the project, and set your SSH Passphrase in the Version Control Settings.  Your changes won't be lost.

### Method 2:  Terminal/Git
1. Open a terminal/command prompt/git client in the repository directory.
2. *Verify you are not on the main branch*
	- You can check this by running `git branch`.  Your current branch will be green and have a `*` next to it.
	- If you are on the main branch, switch to your branch or create a new one.
		- Switching to your branch:  run `git switch <your branch name>`
		- Creating a branch:  run `git branch <your branch name>`
			- Name the branch based on the feature you’re developing so it is clear what the purpose of the branch is.
	- If your branch is not in the resulting `git branch` output, but you know it exists on the GitHub repository, then your local copy of the repository doesn't know it exists.  You can verify if your branch exists on the GitHub repository by running `git branch -r`.  It will be listed as `origin/<your branch name>`.
		- You can tell your local copy of the repository your branch exists by running `git checkout <your branch name>`.  This will also select your branch for making commits to.
3. Make any changes you want to make.
	- Make sure not to make too many changes per commit though, as you may accidentally break something and not know how to fix it.  Having a working commit from not too long ago can make the process of fixing it easier.
4. Determine which files you need to add to your commit with `git status`.
5. Use `git add <file name>` to add files to your commit.
6. Once all of your files are added to your commit, create a commit using `git commit -m <your commit message>`
	- Your commit message should be a good summary of the changes you have made.
7. To push your changes to your branch on the GitHub repository, run `git push`
	- **Important:**   If you created a new branch, you will need to run `git push --set-upstream origin <your branch name>` for the first push to properly configure things.  You won't need to do this again for your branch after the first push.

### Method 3:  GitHub Desktop
NOTE:  If you want to use GitHub Desktop, using the `HTTPS` version of the clone text might make committing easier.  You won't have to re-clone the repository though.  Go to `Repository > Repository Settings... > Remote` and change the primary remote repository (origin) URL.

1. Add the repository by going to `File > Add local repository` and choosing the location where you cloned the repository.
2. *Verify you are not on the main branch* by checking the `Current branch` dropdown menu in the middle-ish area.  It will be between the `Current repository` dropdown menu and the `Fetch origin` button.
	- If you are on the main branch, either switch your branch or create a new one.
	- Switching branches:
		- Enter the `Current branch` dropdown menu and select your branch.
	- Creating a new branch:
		- Enter the `Current branch` dropdown menu and click the `New branch`  button.
		- Name the branch based on the feature you’re developing so it is clear what the purpose of the branch is.
		- Your new branch will be auto-selected.
3. Make any changes you want to make.
	- Make sure not to make too many changes per commit though, as you may accidentally break something and not know how to fix it.  Having a working commit from not too long ago can make the process of fixing it easier.
4. Verify that the files you want to change are selected.
	- They should be selected by default though.  The checkbox next to each file will be checked if it is.
5. Add a commit message and description.
	- Your commit message should be a good summary of the changes you have made up to that point.
6. Click the `Commit to <your branch name>` button.
7. To push your changes to your branch on the GitHub repository, click the `Publish branch` button, which has now replaced the `Fetch origin` button.



# TODO: Write guide for adding stuff for designers.
Assume designers know nothing as a baseline. Tentative list of things that will need to be added:
- Renaming nodes to what their purpose is.
- Importing models.
- Adding collision to mesh parts.
- Paying attention to the little warning signs and how to fix them.
	- CollisionShape3D being scaled.
- How to resize collision shapes properly.
- How to properly create an interactible NPC.
	- Example interactible NPC setup.
- Creating a dialogue file.
	- By creating the file manually.
	- By using the tool. (text ver.)
	- By using the tool. (ui ver. once it exists)
- Adding audio that plays everywhere.
- Example world scene setup.
	- Placing a player.
	- Placing a player camera.
	- The InputHandler.
- Pushing changes to the github repository.
