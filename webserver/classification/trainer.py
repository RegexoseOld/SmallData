"""
creates two pickle files.
1) single word vector classifier
2) regex mapping.
"""


import os
import spacy
import joblib
import gensim
import gensim.parsing.preprocessing as gsp
import re

import numpy as np
import pandas as pd

from pathlib import Path
from collections import defaultdict

from sklearn.linear_model import SGDClassifier
from sklearn.model_selection import cross_val_score

import warnings

warnings.filterwarnings("ignore")

nlp = spacy.load('de')


def load_model():
    parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    return gensim.models.KeyedVectors.load_word2vec_format(
        os.path.join(parent_dir, 'model_data/german.model'), binary=True)


model = load_model()


def replace_umnlaut(text):
    text = text.replace('ä', 'ae')
    text = text.replace('ö', 'oe')
    text = text.replace('ü', 'ue')
    text = text.replace('ß', 'ss')
    return text


def clean_string(text):
    filters = [replace_umnlaut,
               gsp.strip_tags,
               gsp.strip_multiple_whitespaces,
               gsp.strip_numeric]

    text = text.lower()
    for f in filters:
        text = f(text)
    return text.strip()


def sentence_to_vec_spacy(sentence):
    data_matrix = np.array([word.vector for word in nlp(sentence)])
    return np.mean(data_matrix, axis=0)


def sentence_to_vec_german_model(sentence):
    """
    Warning: return nan, if none of the words in the sentence are known to the model!
    :param sentence:
    :return:
    """
    data_matrix = []
    for word in sentence.split(' '):
        if word in model.index2word:
            data_matrix.append(model.word_vec(word))
        elif word.capitalize() in model.index2word:
            data_matrix.append(model.word_vec(word.capitalize()))
    return np.mean(np.asarray(data_matrix), axis=0)


def vectorize_corpus(texts, vectorizer, categories=None):
    """
    :param texts: a list of texts
    :param vectorizer: the vectorizing callable
    :param categories: an optional list of categories. If provided, a new list of categories is returned,
                        with the cats of the texts removed that have not been vectorized
    :return: an array of vectors. WARNING: if a text cannot be vectorized, it is removed from the corpus!
    """
    if categories is not None and len(texts) != len(categories):
        raise Exception('category and texts input must be of the same shape')

    vectors = []
    return_cats = []
    for idx, text in enumerate(texts):
        vect = vectorizer(text)
        if isinstance(vect, np.ndarray):
            vectors.append(vect)
            if categories is not None:
                return_cats.append(categories[idx])

    if categories:
        return np.asarray(vectors), np.asarray(return_cats)
    else:
        return np.asarray(vectors)


def read_trainingdata_textfiles(trainingdata_path):
    """
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
    """
    keywords_to_cat = defaultdict(list)
    regexes = {}

    for file in Path(trainingdata_path).iterdir():
        if file.suffix == '.txt':
            category = file.stem
            text = file.read_text()
            for keywords in text.split('\n'):
                keywords = keywords.strip()
                keywords = keywords.lower()
                keywords = clean_string(keywords)
                if keywords and keywords[0] != '[':
                    if len(keywords.split(' ')) == 1:
                        keywords_to_cat[keywords].append(category)
                    else:
                        regexes[keywords] = category

    return keywords_to_cat, regexes


def read_trainingdata_utterances(df, min_wc=1, max_wc=np.Inf):
    print('\nReading trainingdata')
    x = []
    y = []

    for i in df.index:
        utt = df['utterance'][i]
        if not isinstance(df['category'][i], float):
            text = clean_string(utt)
            wc = len(text.split(' '))  # word_count
            if min_wc <= wc <= max_wc:
                x.append(text)
                y.append(df['category'][i])

    return x, y


def transform_keywords_to_trainingdata(keywords_to_cat):
    """
    Transforms a dictionary mapping keywords to categories into two lists that can be used
    to train sklearn SGDClassifier objects. Words are transformed into Word2Vec Vectors using
    a gensim model trained on the german Wikipedia
    """
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


def load_regexes(file_path):
    print('\nBuilding regexes')
    df = pd.read_excel(file_path)
    expressions = map(clean_string, df.utterance)
    return dict(zip(expressions, df.Effekt))


def validate_df(frame):
    header = ['user', 'topic', 'link', 'utterance', 'category']
    header.sort()
    frame_header = frame.columns.to_list()
    frame_header.sort()
    if header != frame_header:
        raise Exception('Frame has wrong header: {}'.format(frame_header))


def load_training_files(path_to_td):
    df = pd.DataFrame()
    data_composers = ['Boris', 'Pelle']
    pattern = 'TrainingData{}[0-9][0-9].tsv'
    for file in os.listdir(path_to_td):
        for composer in data_composers:
            if re.search(pattern.format(composer), file):
                path_to_file = os.path.abspath(os.path.join(path_to_td, file))
                print('Loading', path_to_file)
                new_df = pd.read_csv(path_to_file, delimiter='\t')
                validate_df(new_df)
                df = df.append(new_df, ignore_index=True)

    return df.drop_duplicates(['utterance'])  # avoid duplication


if __name__ == '__main__':
    data_path = '../model_data'

    regs = load_regexes(os.path.join(data_path, 'TrainingData_regex.xlsx'))

    df_ml = load_training_files(data_path)

    sentences, cats = read_trainingdata_utterances(df_ml)

    vects, cats = vectorize_corpus(sentences, sentence_to_vec_german_model, categories=cats)
    model = train_clf(vects, cats)

    joblib.dump(regs, os.path.join(data_path, 'regex_mapping.pkl'))
    joblib.dump(model, os.path.join(data_path, 'sgd_clf.pkl'))
