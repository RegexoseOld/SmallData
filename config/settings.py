from os import path

#  Directories
BASE_DIR = path.dirname(path.dirname(path.abspath(__file__)))
DATA_DIR = path.join(BASE_DIR, 'webserver/model_data')

# Song settings
song_file = "bossa_slapstick.json"
song_path = path.join(BASE_DIR, 'config', song_file)

# OSC-Settings
ip = "127.0.0.1"
SONG_ADVANCE_ADDRESS = '/advance'
SONG_BEAT_ADDRESS = '/beat'
INTERPRETER_TARGET_ADDRESS = "/interpreter_input"
SONG_SERVER_PORT = 5020
OSCULATOR_PORT = 5010
OSCULATOR_TARGET_ADDRESS = "/osculator_input"
DISPLAY_TARGET_ADDRESS = "/display_input"
DISPLAY_PORT = 5030
PROCESSING_PORT = 5040


# MIDI-note-to-beat-counter-conversion (for Ableton)
note_to_beat = {
    120: '1',
    121: '2',
    122: '3',
    123: '4',
    124: '5',
    125: '6',
    126: '7',
    127: '8',
    'first_count_in_bar': '1'
}
category_to_note = {
    'praise': 64,
    'lecture': 110,
    'insinuation': 90,
    'dissence': 40,
    'concession': 51
}