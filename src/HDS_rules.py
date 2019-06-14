from collections import namedtuple
import re
from itertools import chain


CAT_COUNT = namedtuple('CatCount', 'name, count')
INTENT_COUNT = namedtuple('IntendCount', ['intent', 'count'])
INTENT2CC = {}
keylist = []
INTENTS = {}
NORMAL_CHANNEL = [0.0 for i in range(29)]
NORMAL_CHANNEL.insert(6, 1.0)
NORMAL_CHANNEL[0] = 0.3
NORMAL_CHANNEL[24] = 1.0
LIVE_CHANNELS = [i for i in range(16)]
CONTROLLERS = [[i for i in range(30)] for x in range(16)]

RULES = {
    CAT_COUNT('Bereitschaft', 1): ['default', '='],
    CAT_COUNT('Bereitschaft', 2): ['faster', '+1'],
    CAT_COUNT('Bereitschaft', 4): ['faster', '='],
    CAT_COUNT('Bereitschaft', 6): ['slower', '='],
    CAT_COUNT('Bereitschaft', 8): ['faster', '+1'],
    CAT_COUNT('Bereitschaft', 9): ['faster', '+1'],
    CAT_COUNT('Bereitschaft', 10): ['faster', '='],
    CAT_COUNT('Bereitschaft', 12): ['slower', '+1'],
    CAT_COUNT('Bereitschaft', 13): ['default', '='],
    CAT_COUNT('Bereitschaft', 20): ['faster', '+1'],
    CAT_COUNT('Positionierung', 1): ['default', '+1'],
    CAT_COUNT('Positionierung', 2): ['half', '='],
    CAT_COUNT('Positionierung', 4): ['double', '+1'],
    CAT_COUNT('Positionierung', 5): ['half', '='],
    CAT_COUNT('Positionierung', 7): ['faster', '+1'],
    CAT_COUNT('Positionierung', 9): ['faster', '+1'],
    CAT_COUNT('Positionierung', 10): ['faster', '='],
    CAT_COUNT('Positionierung', 11): ['double', '+1'],
    CAT_COUNT('Positionierung', 14): ['half', '+1'],
    CAT_COUNT('Positionierung', 20): ['default', '='],
    CAT_COUNT('Absicht', 1): ['faster', '='],
    CAT_COUNT('Absicht', 3): ['faster', '+1'],
    CAT_COUNT('Absicht', 4): ['double', '+1'],
    CAT_COUNT('Absicht', 5): ['faster', '='],
    CAT_COUNT('Absicht', 8): ['double', '+1'],
    CAT_COUNT('Absicht', 9): ['faster', '+1'],
    CAT_COUNT('Absicht', 10): ['half', '+1'],
    CAT_COUNT('Absicht', 11): ['double', '='],
    CAT_COUNT('Absicht', 14): ['slower', '+='],
    CAT_COUNT('Absicht', 20): ['slower', '+1'],
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
    #print('name: {}, count: {}'.format(intent, count))
    INTENTS[INTENT_COUNT(intent, count)] = cat_dict
    return cat_dict

normal_values = category_dict('neutral1',
    LIVE_CHANNELS,
    CONTROLLERS,
    [NORMAL_CHANNEL for _ in range(30)])

prozess_values1 = category_dict('Prozess1', [4, 7, 8, 9], [[26] for i in range(4)], [[0.89] for i in range(4)])
prozess_values2 = category_dict('Prozess2', [4, 7, 8, 9], [[26] for i in range(4)], [[0.78] for i in range(4)])
prozess_values3 = category_dict('Prozess3', [0, 4, 7, 8, 9, 10, 13], list(chain([[3, 26] for i in range(6)], [[19, 20]])),
                                                                             list(chain([[0.45, 0.4] for i in range(6)], [[1.0, 0.55]])))
prozess_values4 = category_dict('Prozess4', [0, 4, 7, 8, 9, 13], list(chain([[3, 26] for i in range(5)], [[19, 20]])),
                                                                             list(chain([[0.55, 0.8] for i in range(5)], [[1.0, 0.62]])))

nutzung_values1 = category_dict('Nutzungskonzept1', [0, 4, 7, 8, 9, 11],
                                list(chain([[2] for i in range(2)], [[2, 26] for i in range(4)])),
                                list(chain([[0.6] for i in range(2)], [[0.22, 0.7] for i in range(4)])))
nutzung_values2 = category_dict('Nutzungskonzept2', [1, 4, 7, 8, 9, 11],
                                list(chain([[2, 26] for i in range(2)], [[2, 11, 26] for i in range(4)])),
                                list(chain([[0.4, 0.7] for i in range(2)], [[0.22, 0.04, 0.5] for i in range(4)])))
nutzung_values3 = category_dict('Nutzungskonzept3', [0, 4, 7, 8, 9, 11],
                                list(chain([[2, 11, 26] for i in range(2)], [[2, 11, 26] for i in range(4)])),
                                list(chain([[0.72, 0.03, 0.95]], [[0.72, 0.03, 0.6]], [[0.33, 0.2,  0.8] for i in range(4)])))
nutzung_values4 = category_dict('Nutzungskonzept4', [0, 4, 6, 7, 8, 9, 11],
                                list(chain([[2, 11, 26] for i in range(2)], [[2, 11, 26] for i in range(5)])),
                                list(chain([[0.7, 0.1, 0.95]], [[0.7, 0.1, 0.9]], [[0.2, 0.28, 0.7] for i in range(5)])))
nutzung_values5 = category_dict('Nutzungskonzept5', [0, 4, 7, 8, 9, 11],
                                list(chain([[2] for i in range(2)], [[2, 26] for i in range(4)])),
                                list(chain([[0.6] for i in range(2)], [[0.22, 0.7] for i in range(4)])))
nutzung_values6 = category_dict('Nutzungskonzept6', [0, 4, 7, 8, 9, 11],
                                list(chain([[2, 26] for i in range(2)], [[2, 11, 26] for i in range(4)])),
                                list(chain([[0.4, 0.99]], [[0.4, 0.7]], [[0.22, 0.04, 0.5] for i in range(4)])))
nutzung_values7 = category_dict('Nutzungskonzept7', [0, 4, 6, 7, 8, 9, 11],
                                list(chain([[2, 11, 26] for i in range(2)], [[2, 11, 26] for i in range(5)])),
                                list(chain([[0.7, 0.1, 0.9] for i in range(2)], [[0.2, 0.28, 0.7] for i in range(5)])))
leitbild_values1 = category_dict('Leitbild1', [0, 4, 7, 13], list(chain([[0, 1, 2] for i in range(3)], [[9, 10]])),
                              list(chain([[0.2, 0.2, 0.2] for i in range(3)], [[0.9, 0.3]])))
leitbild_values2 = category_dict('Leitbild2', [0, 4, 7, 9, 13],
                                 list(chain([[0, 1, 2] for i in range(4)], [[9, 10]])),
                              list(chain([[0.4, 0.2, 0.3] for i in range(3)], [[0.1, 0.2, 0.5]], [[0.8, 0.7]])))
leitbild_values3 = category_dict('Leitbild3', [0, 4, 8, 9, 13], list(chain([[0, 1, 2] for i in range(4)], [[9, 10, 11]])),
                              list(chain([[0.6, 0.2, 0.1]], [[0.4, 0.2, 0.6] for i in range(3)], [[0.94, 0.5, 0.4]])))
leitbild_values4 = category_dict('Leitbild4', [0, 4, 7, 8, 9, 13], list(chain([[0, 1, 2] for i in range(5)], [[9, 11]])),
                              list(chain([[0.3, 0.1, 0.2] for i in range(5)], [[0.1, 0.5]]))) # reverb und flanger
leitbild_values5 = category_dict('Leitbild5', [0, 4, 7, 13], list(chain([[0, 1, 2] for i in range(3)], [[9, 10]])),
                              list(chain([[0.2, 0.2, 0.2] for i in range(3)], [[0.9, 0.3]])))
leitbild_values6 = category_dict('Leitbild6', [0, 4, 7, 13], list(chain([[0, 1, 2] for i in range(3)], [[9, 10]])),
                              list(chain([[0.2, 0.2, 0.2] for i in range(3)], [[0.9, 0.3]])))
stadtbau_values1 = category_dict('Staedtebau1', [0, 4, 7, 8, 9, 10, 14],
                                 list(chain([[3, 4, 14] for i in range(6)], [[22, 23]])),
                                list(chain([[0.1, 1.0, 0.3] for i in range(6)], [[1.0, 0.7]]))) # starke und schnelle modulation
stadtbau_values2 = category_dict('Staedtebau2', [0, 4, 7, 8, 9, 10, 14],
                                 list(chain([[3, 4, 14, 16] for i in range(6)], [[22, 23]])),
                                list(chain([[0.2, 0.98, 0.2, 0.6]],[[0.4, 0.98, 0.2, 0.6] for i in range(5)], [[1.0, 0.6]]))) # starke und schnelle modulation
stadtbau_values3 = category_dict('Staedtebau3', [0, 4,  7, 8, 9, 10, 14],
                                 list(chain([[3, 4, 14, 16] for i in range(6)], [[22, 23]])),
                                list(chain([[0.0, 10, 0.4, 0.2] for i in range(6)], [[1.0, 0.6]]))) # starke und schnelle modulation
stadtbau_values4 = category_dict('Staedtebau4', [0, 4, 6, 7, 8, 9, 10, 14],
                                 list(chain([[3, 4, 14, 16] for i in range(7)], [[22, 23]])),
                                list(chain([[0.1, 0.92, 0.6, 0.33]],[[0.7, 0.92, 0.6, 0.33] for i in range(6)], [[1.0, 0.3]]))) # starke und schnelle modulation
stadtbau_values5 = category_dict('Staedtebau5', [0, 4, 7, 8, 9, 10, 14],
                                 list(chain([[3, 4, 14] for i in range(6)], [[22, 23]])),
                                list(chain([[0.1, 1.0, 0.3] for i in range(6)], [[1.0, 0.7]]))) # starke und schnelle modulation
