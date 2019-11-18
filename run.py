import subprocess
import os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("app")

args = parser.parse_args()
current_dir = os.path.abspath(__file__)

if args.app == 'backend':
    p = subprocess.check_call(["python", "backend/manage.py", "runserver"])
elif args.app == 'song':
    p = subprocess.check_call(["python", "song/song_server.py"])
elif args.app == 'frontend':
    os.chdir('frontend')
    p = subprocess.check_call(["npm", "start"])
