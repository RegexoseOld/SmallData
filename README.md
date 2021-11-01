# SmallData

## Installation
* clone git repo
* place `german.model` in `webserver/model_data`
* install language model for spacey `python -m spacy download de`
* Setup backend:
  * Change into `backend` directory and run `python manage.py makemigrations` and `python manage.py migrate`
  * Start server by running `python manage.py runserver`
  * Create categories via `localhost:8000/api/categories` in your browser
* Setup frontend:
  *  Change into `frontend` directrory and type `npm install`
 
 

## Running

The entire application consists of several apps that communicate via OSC. The infrastructure to start those apps is capsuled in the script `run.py` in the repo's root directory.
### Backend
 * contains the rest-api, the database and the logic for classification (the *interpreter*). 
 * start by running `python run.py backend`
### Frontend
 * contains the code for the web-client, where users can enter utterances 
 * start by running `python run.py frontend` from repo's root directory
### Song
 * contains the logic to update the song status given the entered utterances
 * start by running `python run.py song`
### Display
 * a pygame display that shows the song progress, user input, classification results, etc... 
 * start by running `python run.py display`
### Interpreter
 * A mock to simulate the operation of the frontend-backend, sends random utterances and categories.
 * start by running `python run.py interpreter`
### Osculator
 * A mock to simulate the operation of the osculator, sends beat-information to the display.
 * start by running `python run.py osculator`



## Dependencies
 - python 3
 - python-osc
 - spacy
 - gensim
 - joblib
 - django
 - django-import-export
 - django-cors-headers
 - django-rest-framework
 - django-channels
 - sklearn
 - npm
 - pyttsx3

