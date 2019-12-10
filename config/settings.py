from os import path

#  Directories
BASE_DIR = path.dirname(path.dirname(path.abspath(__file__)))
DATA_DIR = path.join(BASE_DIR, 'webserver/model_data')

# Song settings
song_file = 'praise.json'
song_path = path.join(BASE_DIR, 'config', song_file)

# OSC-Settings
ip = "127.0.0.1"
INTERPRETER_TARGET_ADDRESS = "/interpreter_input"
INTERPRETER_PORT = 5020
OSCULATOR_PORT = 5010
OSCULATOR_TARGET_ADDRESS = "/osculator_input"
DISPLAY_TARGET_ADDRESS = "/display_input"
DISPLAY_PORT = 5030


# MIDI-note-to-beat-counter-conversion (for Ableton)
note_to_beat = {
    121: '1',
    122: '2',
    123: '3',
    124: '4'
}
