extends Node

func _on_start_button_pressed() -> void:
	startTests()

func printResults(results:Dictionary) -> void:
	for key in results:
		if results[key]:
			print_rich(key, ": [color=green]PASS[/color]")
		else:
			print_rich(key, ": [color=red][b]FAIL[/b][/color]")


func startTests() -> void:
	var results:Dictionary = {}

	results.merge(test_AudioLoader())

	printResults(results)

func test_AudioLoader() -> Dictionary:
	var prefix:String = "test_AudioLoader_"
	var batch:Dictionary = {}
	var result:Error

	var dummyStream:AudioStreamRandomizer = AudioStreamRandomizer.new()

	result = AudioLoader.loadSfxFromId("", dummyStream)
	batch[prefix + "loadSfxFromId_empty-ID"] = (
		result == Error.ERR_INVALID_DATA and
		dummyStream.streams_count == 0
	)

	result = AudioLoader.loadSfxFromId("none", dummyStream)
	batch[prefix + "loadSfxFromId_ID-none"] = (
		result == Error.OK and
		dummyStream.streams_count == 0
	)

	result = AudioLoader.loadSfxFromId("thisIdDoesNotExist", dummyStream)
	batch[prefix + "loadSfxFromId_ID-no-exist"] = (
		result == Error.ERR_DOES_NOT_EXIST and
		dummyStream.streams_count == 0
	)

	result = AudioLoader.loadSfxFromId("_test_empty", dummyStream)
	batch[prefix + "loadSfxFromId_ID-no-audio"] = (
		result == Error.ERR_DOES_NOT_EXIST and
		dummyStream.streams_count == 0
	)

	# above tests shouldn't result in dummyStream having entries
	AudioLoader.loadSfxFromId("_test_1", dummyStream)
	batch[prefix + "loadSfxFromId_valid-ID-with-audio"] = (dummyStream.streams_count == 3)

	AudioLoader.clearAudioRandomizer(dummyStream)
	batch[prefix + "clearAudioRandomizer"] = (dummyStream.streams_count == 0)

	# stream count for dummyStream should be 0
	var dummyPlayer:AudioStreamPlayer = AudioStreamPlayer.new()
	dummyPlayer.stream = dummyStream
	var toLoad:Dictionary = {
		"event2": "",
		"event3": "_test_1",
		"event4": "_test_1",
		"event5": "_test_1",
	}
	var players:Dictionary[String, AudioStreamPlayer] = {
		"event2": AudioStreamPlayer.new(),
		# nothing for event3
		"event4": AudioStreamPlayer.new(),
		"event5": dummyPlayer
	}
	AudioLoader.loadSfxIntoPlayers(toLoad, players)

	batch[prefix + "loadSfxIntoPlayers_no-ID-to-load"] = (
		players.event2.stream == null
	)
	batch[prefix + "loadSfxIntoPlayers_no-player-for-event"] = (
		not players.has("event3")
	)
	batch[prefix + "loadSfxIntoPlayers_event-player-no-randomizer"] = (
		players.event4.stream is not AudioStreamRandomizer
	)
	batch[prefix + "loadSfxIntoPlayers_valid"] = (
		players.event5.stream.streams_count == 3
	)

	return batch
