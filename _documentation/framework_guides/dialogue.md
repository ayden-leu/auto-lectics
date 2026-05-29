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