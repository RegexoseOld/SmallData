from collections import namedtuple
import re
from itertools import chain

from backend.classification.Categories import CATEGORY_NAMES


CAT_COUNT = namedtuple('CatCount', 'name, count')
INTENT_COUNT = namedtuple('IntendCount', ['intent', 'count'])
INTENT2CC = {}
keylist = []
INTENTS = {}
NORMAL_CHANNEL = [0.0 for i in range(29)]
NORMAL_CHANNEL.insert(6, 1.0)

# simple notes for a simple feedback of the MusicServer
SIMPLE_NOTES = {CATEGORY_NAMES[k]: (60 + k) for k in range(len(CATEGORY_NAMES)) }

RULES = {
    CAT_COUNT('Nerv', 1): ['slower', '='],
    CAT_COUNT('Nerv', 2): ['half', '-1'],
    CAT_COUNT('Nerv', 3): ['default', '+1'],
    CAT_COUNT('Nerv', 5): ['slower', '+3'],
    CAT_COUNT('Zugestaendnis', 1): ['faster', '='],
    CAT_COUNT('Zugestaendnis', 2): ['faster', '+2'],
    CAT_COUNT('Zugestaendnis', 4): ['faster', '+3'],
    CAT_COUNT('Positionierung', 4): ['faster', '+3'],
    CAT_COUNT('Positionierung', 4): ['faster', '+3'],
    CAT_COUNT('Positionierung', 4): ['faster', '+3'],
    CAT_COUNT('Lob', 1): ['faster', '='],
    CAT_COUNT('Absicht', 2): ['faster', '+1'],
    CAT_COUNT('Lob', 4): ['slower', '-1'],
    CAT_COUNT('Lob', 4): ['slower', '-2'],
    CAT_COUNT('Zweifel', 1): ['slower', '='],
    CAT_COUNT('Zweifel', 2): ['half', '-1'],
    CAT_COUNT('Zweifel', 3): ['default', '+1'],
    CAT_COUNT('Zweifel', 5): ['faster', '+2'],
    CAT_COUNT('Belehrung', 1): ['faster', '='],
    CAT_COUNT('Belehrung', 2): ['default', '+1'],
    CAT_COUNT('Gaga', 4): ['slower', '-1'],
    CAT_COUNT('Belehrung', 5): ['half', '-2'],
    CAT_COUNT('Belehrung', 7): ['viertel', '-4'],
    CAT_COUNT('Bereitschaft', 2): ['faster', '+1'],
    CAT_COUNT('Bemuehung', 4): ['double', '+3'],
    CAT_COUNT('Bemuehung', 5): ['4x', '+5'],
    CAT_COUNT('Ablehnung', 1): ['double', '='],
    CAT_COUNT('Ablehnung', 3): ['faster', '-7'],
    CAT_COUNT('Ablehnung', 4): ['4x', '-1'],
    CAT_COUNT('Ablehnung', 5): ['faster', '-5'],
    CAT_COUNT('Loesung', 1): ['double', '='],
    CAT_COUNT('Loesung', 3): ['faster', '+4'],
    CAT_COUNT('Loesung', 4): ['double', '+4'],
    CAT_COUNT('Loesung', 5): ['4x', '+4'],
}

# for key, rule in sorted(list(RULES.items())):
#     print('{}x {} :  {}'.format(key.count, key.name, rule))

def category_dict(name, channel, ccnr, ccval):
    cat_dict = {}
    sub_dicts = []

    for k in range(len(channel)):
        for v in range(len(ccnr[k])):
            #print('ccnr: ', ccnr)
            dict = {ccnr[k][v]: ccval[k][v]}
            sub_dicts.append(dict)

        cat_dict['channel_{}'.format(channel[k])] = sub_dicts
        sub_dicts = []
            #print('subdicts: ', sub_dicts)

    intent = re.sub(r'\d*', '', name)
    count = int(re.sub(r'\D', '', name))
    # print('name: {}, count: {}'.format(intent, count))
    INTENTS[INTENT_COUNT(intent, count)] = cat_dict
    return cat_dict

normal_values = category_dict('neutral1',
    [i for i in range(16)],
    [[i for i in range(30)] for x in range(16)],
    [NORMAL_CHANNEL for _ in range(30)])

messy_values1 = category_dict('messy1', [6, 7, 8, 9], [[20] for i in range(4)], [[1.0] for i in range(4)])
messy_values2 = category_dict('messy2', [2, 4, 5, 6, 7], [[20] for i in range(5)], [[1.0] for i in range(5)])
messy_values3 = category_dict('messy3', [2, 4, 5, 6, 7], [[1, 14] for i in range(5)], [[0.2, 0.3] for i in range(5)])
messy_values4 = category_dict('messy4', [2, 4, 5, 6, 7], [[1, 14] for i in range(5)], [[0.4, 0.4] for i in range(5)])
toxic_values1 = category_dict('toxic1', [6, 7, 8, 9], [[9] for i in range(4)], [[0.1] for i in range(4)])
toxic_values2 = category_dict('toxic2', [6, 7, 8, 9], [[9] for i in range(4)], [[0.3] for i in range(4)])
toxic_values3 = category_dict('toxic3', [1, 2, 4, 5, 6, 7, 8, 9], [[9] for i in range(8)], [[0.65] for i in range(8)])
toxic_values4 = category_dict('toxic4', [1, 2, 4, 5, 6, 7, 8, 9], [[9] for i in range(8)], [[0.85] for i in range(8)])
irritate_values1 = category_dict('irritate1', [1, 2, 6, 7, 8, 9], [[14, 4] for i in range(6)], [[0.18, 0.65] for i in range(6)])
irritate_values2 = category_dict('irritate2', [1, 2, 7, 8, 9], [[14, 4] for i in range(5)], [[0.25, 0.6] for i in range(5)])
irritate_values3 = category_dict('irritate3', [1, 2, 7, 8, 9], [[14, 4, 17] for i in range(5)], [[0.25, 0.02, 0.5] for i in range(5)])
irritate_values4 = category_dict('irritate4', [0, 1, 2, 7, 8, 9], [[14, 4, 17, 20] for i in range(6)], [[0.30, 0.8, 0.2, 1.0] for i in range(6)])
puzzle_values1 = category_dict('puzzle1', [1, 4, 5, 6, 7, 8, 9 ], [[14, 16] for i in range(7)], [[0.2, 0.5] for i in range(7)])
puzzle_values2 = category_dict('puzzle2', [1, 2, 4, 5, 6, 7], [[14, 4, 16] for i in range(6)], [[0.32, 0.7, 0.3] for i in range(6)])
puzzle_values3 = category_dict('puzzle3', [1, 2, 4, 5, 6, 7], [[14, 4, 16, 10] for i in range(6)], [[0.32, 0.8, 0.3, 1.0] for i in range(6)])
puzzle_values4 = category_dict('puzzle4', [1, 2, 4, 5, 6, 7], [[14, 4, 16, 10, 20] for i in range(6)], [[0.32, 0.8, 0.3, 1.0, 1.0] for i in range(6)])

dream_values1 = category_dict('dream1', [6, 7, 8, 9, 13], list(chain([[0, 1, 2] for i in range(4)], [[9, 10, 11]])),
                              list(chain([[0.2, 0.2, 0.5] for i in range(4)], [[0.4, 0.4, 0.0]])))
dream_values2 = category_dict('dream2', [6, 7, 8, 9, 13], list(chain([[0, 1, 2] for i in range(4)], [[9, 10, 11]])),
                              list(chain([[0.2, 0.2, 0.75] for i in range(4)], [[0.7, 0.45, 0.2]])))
dream_values3 = category_dict('dream3', [6, 7, 8, 9, 13], list(chain([[0, 1, 2] for i in range(4)], [[9, 10, 11]])),
                              list(chain([[0.2, 0.2, 0.8] for i in range(4)], [[0.88, 0.55, 0.6]]))) # reverb und flanger
dream_values4 = category_dict('dream4', [0, 1, 2, 3, 4, 6, 7, 8, 9, 13], list(chain([[0, 1, 2] for i in range(9)], [[9, 10, 11]])),
                              list(chain([[0.3, 0.3, 0.6] for i in range(5)], [[0.2, 0.2, 0.8] for i in range(4)], [[0.88, 0.55, 0.6]]))) # reverb und flanger
wobble_values1 = category_dict('wobble1', [6, 7, 8, 9], [[10, 11, 12] for i in range(4)], [[1.0, 0.2, 0.4] for i in range(4)]) # starke und schnelle modulation
wobble_values2 = category_dict('wobble2', [6, 7, 8, 9], [[10, 11, 12] for i in range(4)] , [[1.0, 0.35, 0.4] for i in range(4)]) # starke und schnelle modulation
wobble_values3 = category_dict('wobble3', [6, 7, 8, 9], [[10, 11, 12] for i in range(4)], [[1.0, 0.4, 0.4] for i in range(4)]) # starke und schnelle modulation
wobble_values4 = category_dict('wobble4', [6, 7, 8, 9], [[10, 11, 12] for i in range(4)], [[1.0, 0.9, 0.4] for i in range(4)]) # starke und schnelle modulation
blurry_values1 = category_dict('blurry1', [15], [[9, 10, 11]], [[1.0, 0.85, 0.0]]) # nur frequenz
blurry_values2 = category_dict('blurry2', [15], [[9, 10, 11]], [[1.0, 0.65, 0.0]]) # nur frequenz
blurry_values3 = category_dict('blurry3', [15], [[9, 10, 11]], [[1.0, 0.5, 0.0]]) # nur frequenz
blurry_values4 = category_dict('blurry4', [15], [[9, 10, 11]], [[1.0, 0.25, 0.0]]) # nur frequenz
