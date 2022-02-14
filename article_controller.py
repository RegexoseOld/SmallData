import tkinter as tk
import os
import csv


TEMPLATE_FILE = "Kommentarvorlage.csv"


class Gui(tk.Tk):
    __size = '530x420'
    __title = "Parameter controller"

    def __init__(self, **kwargs):
        super(Gui, self).__init__(**kwargs)

        self.title(self.__title)
        self.geometry(self.__size)

        self.__create_dropdown()
        self.__create_article_areas()
        self.__create_send_button()

    def __create_dropdown(self):
        with open(os.path.join('config', TEMPLATE_FILE), mode='r') as file:
            csv_file = csv.DictReader(file, delimiter=";")
            self.article_collection = {line["Name"]: line["Text"] for line in csv_file}

        self.article = tk.StringVar(self)
        self.article.trace("w", self.__select_article_cb)

        tk.Label(self, text="Article selector", width=10).pack()
        self.article_selector = tk.OptionMenu(self, self.article, *self.article_collection.keys())
        self.article_selector.pack()

    def __create_article_areas(self):
        tk.Label(self, text="Current article", width=20).pack(side=tk.TOP)
        self.current_article = tk.Text(self, width=80, height=10)
        self.current_article.pack()
        tk.Label(self, text="Next article", width=20).pack(side=tk.TOP)
        self.next_article = tk.Text(self, width=80, height=10)
        self.next_article.pack()

    def __create_send_button(self):
        self.send_button = tk.Button(self, text="Send", command=self.__send_cb)
        self.send_button.pack()

    def __send_cb(self, *args):
        self.current_article.delete("1.0", "end")
        self.current_article.insert("1.0", self.next_article.get("1.0", "end - 1 chars"))
        self.next_article.delete("1.0", "end")

    def __select_article_cb(self, *args):
        self.next_article.delete("1.0", "end")
        self.next_article.insert("1.0", self.article_collection[self.article.get()])

    def start(self):
        self.article.set(list(self.article_collection.keys())[0])
        self.__select_article_cb()
        self.mainloop()


if __name__ == "__main__":
    gui = Gui()
    gui.start()
