extends Node

# signals

signal message_received

# variables

# we will buffer audio from the mic and send it out to Deepgram in reasonably sized chunks
var audio_buffer: PoolRealArray

# the WebSocketClient which allows us to connect to Deepgram
var client = WebSocketClient.new()
var ws_connected = false

# functions

# a helper function to convert f32 pcm samples to i16
func f32_to_i16(f: float):
	f = f * 32768
	if f > 32767:
		return 32767
	if f < -32768:
		return -32768
	return int(f)

# a convenience function to delete this node
func delete():
	print("Destroying DeepgramInstance")
	get_tree().queue_delete(self)

func _ready():
	print("DeepgramInstance ready!")


func initialize(api_key):
	var mix_rate = AudioServer.get_mix_rate()

	# start recording from the mic (actually this only starts capture of the recording I think)
	$MicrophoneInstance.recording = true

	# connect base signals to get notified of connection open, close, and errors
	client.connect("connection_closed", self, "_closed")
	client.connect("connection_error", self, "_closed")
	client.connect("connection_established", self, "_connected")
	client.connect("data_received", self, "_on_data")

	# this is how we authenticate with Deepgram using an api key
	# N.B. this will not work with HTML5 exports!
	var auth_header = "Authorization: Token " + api_key
	var extra_headers = PoolStringArray([auth_header])
	
	# connect to Deepgram - note we must specify the raw audio format
	var err = client.connect_to_url("wss://api.deepgram.com/v1/listen?encoding=linear16&sample_rate=" + String(mix_rate) + "&channels=1", PoolStringArray(), false, extra_headers)
	if err != OK:
		print("Unable to connect")
		emit_signal("message_received", "unable to connect to deepgram;")
		set_process(false)

func _closed(was_clean = false):
	print("Closed, clean: ", was_clean)
	emit_signal("message_received", "connection to deepgram closed;")
	set_process(false)

func _connected(_proto):
	print("Connected to Deepgram!")
	ws_connected = true

func _on_data():
	# receive a message from Deepgram!
	var message = client.get_peer(1).get_packet().get_string_from_utf8()
	
	# emit the message from Deepgram as a signal
	emit_signal("message_received", message)

func _process(_delta):
	client.poll()

func _on_MicrophoneInstance_audio_captured(mono_data):
	audio_buffer.append_array(mono_data)
	# TODO: consider using `set_encode_buffer_max_size(value)` to increase the packet size
	# this might allow us to stream slower and possibly improve performance
	if audio_buffer.size() >= 1024 * 40 * 0.5 and ws_connected == true:
		# convert the f32 pcm to linear16/i16 pcm
		# this is a bit hacky, but godot doesn't seem to offer too much flexibility with low-level types
		var linear16_audio: PoolByteArray = []
		for sample in audio_buffer:
			linear16_audio.append(f32_to_i16(sample))
			linear16_audio.append(f32_to_i16(sample) >> 8)
		# send the audio to Deepgram!
		client.get_peer(1).put_packet(linear16_audio)
		audio_buffer = PoolRealArray()
