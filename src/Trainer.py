'''
creates two pickle files.
1) single word vector classifier
2) regex mapping.


'''
import os
import spacy
import joblib
import gensim

import numpy as np
import pandas as pd

from pathlib import Path
from collections import defaultdict

from sklearn.linear_model.stochastic_gradient import SGDClassifier
from sklearn.model_selection import cross_val_score

import warnings

warnings.filterwarnings("ignore")

nlp = spacy.load('de')
model = gensim.models.KeyedVectors.load_word2vec_format('../model_data/german.model', binary=True)


def replace_umlaut(text):
    text = text.lower()
    text = text.replace('ä', 'ae')
    text = text.replace('ö', 'oe')
    text = text.replace('ü', 'ue')
    text = text.replace('ß', 'ss')
    return text


def sent_to_vects(sentence):
    return [word.vector for word in nlp(sentence)]


def word_to_vect(word):
    # return nlp(word).vector
    if word in model.index2word:
        return model.word_vec(word)
    elif word.capitalize() in model.index2word:
        return model.word_vec(word.capitalize())
    else:
        return None


def read_trainingdata_textfiles(trainingdata_path):
    '''
    Reads all trainingdata texfiles in a directory. The textfiles can contain single words and regular expressions.
    Every line containing more than one word ist considered a regular expression
    lines starting with "[" are ignored.
    An example trainingdata file could look like this:

    [words]
    word1
    word2

    [regexes]
    word .* another three words
    ^Begin .* like this


    The function returns 2 dictionaries:  One with single words as keys and categories as values
                                          One with regexes as keys and categories as values

    all umlauts are replaced and words are lowercases.
    '''
    keywords_to_cat = defaultdict(list)
    regexes = {}

    for file in Path(trainingdata_path).iterdir():
        if file.suffix == '.txt':
            category = file.stem
            text = file.read_text()
            for keywords in text.split('\n'):
                keywords = keywords.strip()
                keywords = keywords.lower()
                keywords = replace_umlaut(keywords)
                if keywords and keywords[0] != '[':
                    if len(keywords.split(' ')) == 1:
                        keywords_to_cat[keywords].append(category)
                    else:
                        regexes[keywords] = category

    return keywords_to_cat, regexes


def read_trainingdata_utterances(df):
    '''
    should read all lines of a Excel column. The textfiles can contain single words and regular expressions.
    Every line containing more than one word ist considered a regular expression
    lines starting with "[" are ignored.
    An example trainingdata file could look like this:

    [words]
    word1
    word2

    [regexes]
    word .* another three words
    ^Begin .* like this


    The function returns 2 dictionaries:  One with single words as keys and categories as values
                                          One with regexes as keys and categories as values

    all umlauts are replaced and words are lowercases.
    '''
    keywords_to_cat = defaultdict(list)
    regexes = {}
    line = 0

    for i in df.index:
        utt = df['utterance'][i]
        if not isinstance(df['Effekt'][i], float):
            effekt = df['Effekt'][i]
        else:
            effekt = 'not yet defined'

        line +=1
        for keywords in utt.split('\n'):
            keywords = keywords.strip()
            keywords = keywords.lower()
            keywords = replace_umlaut(keywords)
            if keywords and keywords[0] != '[':
                if len(keywords.split(' ')) == 1:
                    #if its one word only
                    keywords_to_cat[keywords].append(effekt)
                    # print('for keyword {} in line {} appended: {}'.format(keywords, line, effekt) + '\n')
                else:
                    # else if its more than one word
                    regexes[keywords] = effekt
    return keywords_to_cat, regexes


def transform_keywords_to_trainingdata(keywords_to_cat):
    '''
    Transforms a dictionary mapping keywords to categories into two lists that can be used
    to train sklearn SGDClassifier objects. Words are transformed into Word2Vec Vectors using
    a gensim model trained on the german Wikipedia
    '''
    x, y = [], []
    # print('139 keywords2cat: ', keywords_to_cat)

    for word, category in keywords_to_cat.items():
        vect = word_to_vect(word)
        if vect is not None:
            x.append(vect)
            y.append(category)


    x = np.asarray(x)
    y = np.asarray(y)

    return x, y


def train_clf(x, y):
    clf = None
    best = 0
    print('\nTraining SGD Classifier')
    for i in range(200):
        temp_clf = SGDClassifier(tol=1e-3, max_iter=1000, random_state=i, loss='modified_huber')
        # print('x: {}\ny: {} '.format(x, y))
        score = np.mean(cross_val_score(temp_clf, x, y, cv=5, scoring='f1_weighted'))
        temp_clf.fit(x, y)

        if score > best:
            best = score
            clf = temp_clf
    print('\nAverage F1 Score {: .2f}%'.format(np.mean(best) * 100))
    return clf


def load_data_and_train_model(df):
    '''
    was:    get texts from txt files in a folder
    keywords_to_cat, regexes = read_trainingdata_textfiles(trainingdata_path)
    '''
    keywords_to_cat, regexes = read_trainingdata_utterances(df)
    print('Keywords with multiple categories are ignored\n')
    for keyword, cats in list(keywords_to_cat.items()):
        if len(cats) > 1:
            print('{:<20} {}'.format(keyword, cats))
            del keywords_to_cat[keyword]
        else:
            keywords_to_cat[keyword] = cats[0]

    x, y = transform_keywords_to_trainingdata(keywords_to_cat)
    clf = train_clf(x, y)
    return clf, regexes


if __name__ == '__main__':
    data_path = '../backend/model_data'
    data_frame = pd.read_excel(os.path.join(data_path, 'TrainingData_clean_de.xlsx'))
    clf, regexes = load_data_and_train_model(data_frame)

    joblib.dump(regexes, os.path.join(data_path, 'regex_mapping.pkl'))
    joblib.dump(clf, os.path.join(data_path,'sgd_clf.pkl'))