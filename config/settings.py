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
SONG_RACK_ADDRESS = '/rack'
SONG_MIDICC_ADDRESS = '/control'
SONG_QUITTUNG_ADDRESS = '/quittung'
SONG_ARP_ADDRESS = '/arp'
SONG_BEAT_ADDRESS = '/beat'
INTERPRETER_TARGET_ADDRESS = "/interpreter_input"
SONG_SERVER_PORT = 5020
OSCULATOR_PORT = 5010
OSCULATOR_TARGET_ADDRESS = "/osculator_input"
DISPLAY_UTTERANCE_ADDRESS = "/display_input"
DISPLAY_PARTINFO_ADDRESS = "/display_partinfo"
DISPLAY_INIT_ADDRESS = "/display_init"
DISPLAY_PORT = 5030
AUDIENCE_PORT = 5040
PERFORMER_PORT = 5050


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
category_to_samplenotes = {
    'praise': [24, 27, 25, 26, 28],
    'lecture': [11, 8, 9, 10, 9],
    'insinuation': [13, 14, 15, 12, 17],
    'dissence': [22, 18, 20, 19, 21],
    'concession': [32, 33, 34, 31, 35]
}

category_to_quittung = {}

note_durations = [0.25, 0.5, 1.0, 1.5, 2.0, 2.5, 4.0, 5.0]
rack_chains = [3, 6, 8]

category_to_arpeggiator = {
    # category has fixed values for all relevant controllers of Arpeggiator as defined in arp_controls
    'praise': [100, 20, 100, 100, 115],
    'lecture': [108, 10, 120, 108, 115],
    'insinuation': [115, 120, 108, 50, 100],
    'dissence': [110, 70, 110, 25, 115],
    'concession': [50, 5, 40, 110, 90],
}

arp_controls = {
    # each control has a ccnr from  30 onwards see ccnrs of chain_controls
    'Rate': 31,
    'Gate': 32,
    'Steps': 33,
    'Distance': 34,
    'Decay': 35
}