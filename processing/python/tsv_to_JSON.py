import csv
import json

csvFilePath = '../../webserver/model_data/TrainingDataPelle01.tsv'
jsonFilePath = '/Users/borisjoens/Desktop/TrainingDataPelle01.json'

def make_json(csvFilePath, jsonFilePath):
    data = {}
    indx = 0
    with open(csvFilePath, encoding='utf-8') as csvf:
        csvreader = csv.DictReader(csvf, delimiter='\t')
        for rows in csvreader:
            data[indx] = rows
            indx += 1

    with open(jsonFilePath, 'w', encoding='utf-8') as jsonf:
        jsonf.write(json.dumps(data, indent=4))


make_json(csvFilePath, jsonFilePath)