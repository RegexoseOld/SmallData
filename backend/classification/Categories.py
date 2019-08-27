import os
import collections
import pickle
import pandas as pd
from pandas import ExcelWriter
from pandas import ExcelFile

# dir_path = '/Users/borisjoens/Dropbox/Kommentare/SmallData/backend/classification'
dir_path = os.path.dirname('/Users/borisjoens/Dropbox/Kommentare/SmallData/backend/model_data/')
df = pd.read_excel(os.path.join(dir_path,'TrainingData_clean_de.xlsx'))

NORMAL_CHANNEL= [0.0 for i in range(29)]
NORMAL_CHANNEL.insert(6, 1.0)

CAT2VAL = {}

def p_dict(dict):
    for i in dict.keys():
        print('"{}" : {},\n'.format(i, dict[i]))

# import CATEGORY_NAMES from Excel Data Sheet
imported_categories = []
for cat in df.index:
    imported_categories.append(df['Effekt'][cat])

CATEGORY_NAMES = list(set(imported_categories))

CHANNEL = [[i for i in range(16)] for o in range(len(CATEGORY_NAMES))]

def category_dict(channel, ccnr, ccval):
    cat_dict = collections.OrderedDict()
    sub_dicts = []
    for k in range(len(channel)):
        for v in range(len(ccnr[k])):
            #print('länge von ccnr: ', v)
            dict = {ccnr[k][v] : ccval[k][v]}
            sub_dicts.append(dict)
        cat_dict['channel_{}'.format(channel[k])] = sub_dicts
        sub_dicts = []
    return cat_dict

normal_values = category_dict(
    [i for i in range(16)],
    [[i for i in range(30)] for x in range(16)],
    [NORMAL_CHANNEL for v in range(30)]
)

WHEEL = [-2000, -250 , 10, 8000, 15, -1100, 0, 850]


CCNR = [[i for i in range(19)] for i in range(len(CATEGORY_NAMES))]
CCVAL = [normal_values for i in range(len(CATEGORY_NAMES))]
COARSE = [90, 92, 80, 2, 10, 40, 70, 89]
FINE = [1, 2, 102, 77, 55, 80, 100, 62]
REPEAT = [6, 4, 4, 5, 1, 2, 3, 1]

def dict_values(keys1, wheel, cc_dict, coarse, fine, repeat):
    val_dict = collections.OrderedDict()
    for i in range(len(keys1)):
        val_dict[keys1[i]] = {'cc_dict': cc_dict}
    # print('val_dict: ', val_dict)
    return val_dict

category_values = 'nochmal nachschauen'

if os.path.exists('../model_data/CAT2VAL.pkl'):
    print('pickle exists? ', os.path.exists('../model_data/CAT2VAL.pkl'))

    with open('../model_data/CAT2VAL.pkl', 'rb') as f:
        CAT2VAL = pickle.load(f)
    CAT2VAL['Loesung'] = {'wheel': 2000, 'repeat': 2, 'cc_dict': normal_values, 'coarse': 37, 'fine': 0}
    CAT2VAL['Gaga'] = {'wheel': 8000, 'repeat': 2, 'cc_dict': normal_values, 'coarse': 37, 'fine': 0}
    #print('CAT2VAL nach pickle load: ', p_dict(CAT2VAL) )

else:
    CAT2VAL = dict_values(CATEGORY_NAMES, WHEEL, category_values, COARSE, FINE, REPEAT, )
    #p_dict(CAT2VAL)

    with open(os.path.join(dir_path,'../model_data/CAT2VAL.pkl'), 'wb') as f:
        pickle.dump(CAT2VAL, f, pickle.HIGHEST_PROTOCOL)
