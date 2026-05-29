# Interacting with the GitHub Repository
This section will help you setup a git management tool so you can [push](terminology.md#push) and [pull](terminology.md#pull) changes to and from the repository.

## Index
- [Prelude - Setting a SSH Key](#prelude---setting-a-ssh-key-for-your-github-account-optional)
- [Cloning the GitHub repository](#cloning-the-github-repository)
- [Submitting Changes](#submitting-changes)
	- [Framework](#framework)
	- [Designers](#designers)
- [Commiting Changes](#committing-changes-to-the-github-repository)
	- [Method 1: GitHub Desktop](#method-1--github-desktop)
	- [Method 2: Terminal/Git](#method-2--terminalgit)


## Prelude - Setting a SSH key for your GitHub account (optional)
GitHub has deprecated the easier method of using a username and password to login to git in some cases.  I am not aware if this change applies *everywhere*, but I believe it is best to assume so.  Also, using an SSH method *is* more secure even if there is more setup involved.

If you're using the [GitHub Desktop commit method](#method-3--github-desktop), you won't have to do this.

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


## Cloning the GitHub Repository
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






# Submitting Changes
## Framework
***Please*** follow this methodology so we don't run into complicated [merge conflicts](terminology.md#merge-conflict) down the line.

1. Make sure you are ***not*** on the main branch before you start making changes.  The specifics for finding out which branch you're on depends on your method.
2. Make a [commit](terminology.md#commit) every time you change something so progress is saved.  Your commit message should be a good summary of the changes you have made up to that point.  Smaller commits can make the process of fixing an unknown issue easier.
3. When you are ready to submit your changes to the main branch, push all of your commits to your branch on the repository, then make a Pull Request.
	- To make a pull request, go to your branch on the GitHub website.  There, you should find a noticable green buttom that says "Pull Request."  If not, then click the `Contribute` button and click `Open pull request`.
	- Be descriptive about your changes when writing the pull request title and description.  It'll help the team understand all of your changes.
4. *Do Not Merge Your Pull Request Immediately*.  Wait for another team member to approve of the merge.
	- This will allow the team to read your code and raise any issues they have with your implementation.  These issues can range from self-documentation being unclear to additional or missing features they would like to be implemented.
	- Also, the merge might cause some merge conflicts since merge conflicts are bound to happen.  Sorting this out *before* the merge happens will be ideal.
	- If you are the one to merge the pull request, please copy-paste the original pull request's description into the extended description box.
5. Delete your branch.
	- Once the changes are merged, your branch won’t serve a purpose anymore.  It's recommend you do this even if you decide to immediately work on a new feature as the main branch may have been updated with other changes.

## Designers
The methodology for pushing changes to the designer branch is less strict as to not complicate things for the designer team.

If you're just adding some simple stuff (i.e adding a new model, adding dialogue files), then you can just make a [commit](terminology.md#commit) directly on the `main_designers` branch and push it.
- However, if another person is working on that branch, they'll have to [pull](terminology.md#pull) your changes before they can [push](terminology.md#push) their changes.
- This is usually fine, even if it adds a bit of friction.  However, there is a risk of causing a [merge conflict](terminology.md#merge-conflict).
- Merge conflicts can be resolved by figuring out what stuff to keep and what stuff to discard.  Depending on the changes, this can get very difficult, especially if you're not familiar with a file's format (e.g. Godot scene files).

If you believe your changes will result in a [merge conflict](terminology.md#merge-conflict), follow the instructions outlined in [the framework section above.](#framework)





# Committing Changes to the GitHub Repository
There are a handful of ways to push and pull commits to and from the repository.  This section is mainly for describing how to use the Godot Git Plugin as setting it up can be a bit weird.  *It is important that you follow these steps before making changes.*

First, configure your name and email in git for this project.
1. Open a terminal/command prompt in this project's directory.
2. Run `git config user.name <your GitHub account username>`
3. Run `git config user.email <your GitHub account email>` 

Then, pick a one of the following methods of your choice.  This isn't an exhaustive list, so if you find an alternative that works for you, then go ahead and use that.

## Method 1:  GitHub Desktop
This method is pretty nice as it gives you a [GUI](./terminology.md#GUI) to interact with.

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

## Method 2:  Terminal/Git
If [GitHub Desktop](#method-1--github-desktop) doesn't work for whatever reason, this is one of alternatives you can use.

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

