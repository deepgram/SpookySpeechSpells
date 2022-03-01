extends AudioStreamPlayer

# signals

signal audio_captured

# variables

# set this to true or false to capture audio from the mic or not
export var recording: bool = false
# AudioEffectCapture is the object which allows us to stream raw audio data
var effect_capture: AudioEffectCapture
# helps control the state of the AudioEffectCapture buffer
# when going from not recording -> recording, it will help us clear the AudioEffectCapture buffer
var previous_frame_was_recording = false

# functions

func _ready() -> void:
	# we want to create a new bus with the name "MicrophoneRecorderX"
	# where "X" is an integer
	# this loop ensures we do not accidentally grab a bus which already exists
	var current_number = 0
	while AudioServer.get_bus_index("MicrophoneRecorder" + str(current_number)) != -1:
		current_number += 1
	var bus_name = "MicrophoneRecorder" + str(current_number)

	# create our new bus, mute it (so we don't get feedback from the mic)
	# and add an AudioEffectCapture object to it
	var idx = AudioServer.bus_count
	AudioServer.add_bus(idx)
	AudioServer.set_bus_name(idx, bus_name)
	AudioServer.add_bus_effect(idx, AudioEffectCapture.new())
	AudioServer.set_bus_mute(idx, true)

	# set the bus of this object
	# (by default it is "Master", but we want this object's bus to be the one we just set up)
	bus = bus_name

	# start streaming from the microphone
	# the format of the stream will be f32 pcm samples (given by Godot)
	# at a sample rate given by the OS, but this sample rate
	# can be obtained via AudioServer.get_mix_rate()
	stream = AudioStreamMicrophone.new()
	play()

func _process(_delta: float) -> void:
	process_mic()

func init_effect_capture():
	var idx := AudioServer.get_bus_index(bus)
	effect_capture = AudioServer.get_bus_effect(idx, 0)

func process_mic():
	if recording:
		if effect_capture == null:
			init_effect_capture()

		if previous_frame_was_recording == false:
			effect_capture.clear_buffer()

		# grab the raw audio from the AudioEffectCapture
		var stereo_data: PoolVector2Array = effect_capture.get_buffer(effect_capture.get_frames_available())
		if stereo_data.size() > 0:
			# convert the stereo audio into mono
			var mono_data = PoolRealArray()
			mono_data.resize(stereo_data.size())

			for i in range(stereo_data.size()):
				var value := (stereo_data[i].x + stereo_data[i].y) / 2.0
				mono_data[i] = value

			# emit the audio data
			emit_signal("audio_captured", mono_data)

	previous_frame_was_recording = recording
