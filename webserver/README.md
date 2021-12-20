## Installation
0. run `git clone git@github.com:Regexose/SmallData.git`
1. install python >= 3.8.0
2. run `pip install -r requirements.txt`
3. run `python -m spacy download de_core_news_sm`
4. install sqlite
5. cd into webserver
6. run `python manage.py makemigrations && python manage.py migrate`