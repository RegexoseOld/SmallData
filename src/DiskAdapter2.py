import os
import numpy as np

MODE_ONE_FILE_PER_TEXT = 1
MODE_ONE_FILE_PER_CAT = 2

class DiskAdapter(object):
    DATA_PATH = '../TrainingDataNew'

    def __init__(self, datapath=DATA_PATH):
        self.datapath = datapath
        #print('diskadapter path', self.datapath)

    def get_texts_by_category(self, category, mode=MODE_ONE_FILE_PER_CAT):
        content = []
        if mode == MODE_ONE_FILE_PER_TEXT:
            directory = os.path.join(self.datapath, category)
            for filename in os.listdir(directory):
                if filename[0] != '.':
                    with open(os.path.join(directory, filename)) as f:
                        content.append(f.read().rstrip())
        elif mode == MODE_ONE_FILE_PER_CAT:
            with open(os.path.join(self.datapath, category + ".txt")) as f:
                content = f.readlines()
            content = [text.strip() for text in content]
        return content

    def get_training_data(self, allowed_categories):
        category_ids = []
        category_names = []
        texts = []

        for cat_file in os.listdir(self.datapath):
            category = os.path.splitext(cat_file)[0]
            # print('category DiskAdapter: ', category)
            if cat_file[0] != '.' and category in allowed_categories:
                category_texts = self.get_texts_by_category(category)
                texts.extend(category_texts)
                category_names.extend([category]*len(category_texts))
                category_ids.extend([allowed_categories.index(category)]*len(category_texts))
            # print('texts {}\n category_ids {}\n category_names {}\n'.format(texts, category_ids, category_names))

        return texts, category_ids, category_names

if __name__=='__main__':
    adapter = DiskAdapter()
    res = adapter.get_texts_by_category()
    allowed_categories = ['Tune01', 'Tune02']
    texts, cat_ids, cat_names = adapter.get_training_data(allowed_categories)
    result = np.array([texts, cat_ids, cat_names])
    print('My list:', *result.transpose(), sep='\n- ')

