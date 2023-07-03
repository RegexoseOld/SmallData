from argparse import ArgumentParser
import pandas as pd
import threading
import datetime

parser = ArgumentParser(
                    prog='PlayCsv',
                    description='plays the content of a csv as if it was a live show (send to supercollider)')

parser.add_argument('filename')


def send_data(index, time):
    row = df.iloc[index]
    text = row['Utterance']
    category = row['Category']
    print(text, category)

    index += 1
    if index < len(df):
        set_timer(time, index)
    else:
        print("done")


def set_timer(prev_time, index):
    row = df.iloc[index]
    time = datetime.datetime.strptime(row['Time'], '%H:%M:%S:%f')
    interval = time-prev_time
    t = threading.Timer(interval.total_seconds(), send_data, args=(index, time))
    t.start()


if __name__ == '__main__':
    args = parser.parse_args()
    df = pd.read_csv(args.filename)
    first_row = df.iloc[0]
    first_time = datetime.datetime.strptime(first_row['Time'], '%H:%M:%S:%f')
    set_timer(first_time, 0)
