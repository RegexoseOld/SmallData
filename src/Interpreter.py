from Categories import CAT2VAL


class Interpreter:
    def __init__(self, classifier):
        self.classifier = classifier
        print('Classifier', self.classifier)

    def text2pitch(self, text):
        cat, prob = self.classifier.predict_proba(text, verbose=True)
        print('input {}, cat {}, prob {}: '.format(text, cat, prob))
        velo = CAT2VAL[cat]['velo']
        pitch = CAT2VAL[cat]['pitch']
        return [pitch, velo, cat, prob[0]]

    def text2wheel(self, text):
        cat, prob = self.classifier.predict_proba(text, filter_stop_words=False, verbose=True)
        # print result of last utterance
        print('input {}, cat {}, prob {}: '.format(text, cat, prob))
        wheel = CAT2VAL[cat]['wheel']
        return [wheel, cat, prob]

    def text2repeat(self, text):
        cat, prob = self.classifier.predict_proba(text, verbose=True)
        #print('input {}, cat {}, prob {}: '.format(text, CATEGORY_NAMES[cat], prob))
        repeat = CAT2VAL[cat]['repeat']
        return repeat

    def text2ccval(self, text):
        cat, prob = self.classifier.predict_proba(text, verbose=True)
        print('input {}, cat {}, prob {}: '.format(text, cat, prob))
        cc_dict = CAT2VAL[cat]['cc_dict']
        return cc_dict

    def text2coarse(self, text):
        cat, prob = self.classifier.predict_proba(text, verbose=True)
        #print('input {}, cat {}, prob {}: '.format(text, CATEGORY_NAMES[cat], prob))
        coarse = CAT2VAL[cat]['coarse']
        return coarse

    def text2fine(self, text):
        cat, prob = self.classifier.predict_proba(text, verbose=True)
        fine = CAT2VAL[cat]['fine']
        return fine