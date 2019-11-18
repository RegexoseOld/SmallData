# SmallData

## Installation
 - clone git repo
 - place `german.model` in `model_data`
 - install language model for spacey `python -m spacy download de`
 - Setup backend:
  -- Change into `backend` directory and run `python manage.py makemigrations` and `python manage.py migrate`
  - Start server by running `python manage.py runserver`
  - Create categories via `localhost:8000/api/categories` in your browser
 - Setup frontend:
  -  Change into `frontend` directrory and type `npm install`
 
 

## Running
### backend
 Change into `backend` directory and run `python manage.py runserver`
### frontend
 Change into `frontend` directrory and type `npm start`

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
 - sklearn
 - npm
