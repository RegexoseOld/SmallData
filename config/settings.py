from os import path

#  Directories
BASE_DIR = path.dirname(path.dirname(path.abspath(__file__)))
DATA_DIR = path.join(BASE_DIR, 'webserver/model_data')

# Song settings
song_file = 'heavy_lemon.json'
song_path = path.join(BASE_DIR, 'config', song_file)
