import tkinter as tk

class MyCanvas(tk.Frame):

    def __init__(self, root):
        tk.Frame.__init__(self, root)
        self.master.title('mycanvas')
        self.canvas = tk.Canvas(self, width=400)
        #self.canvas.grid(column=0, row=0, sticky="NSEW")

        self.font = ('Arial', 16)

        # standard bindings
        self.canvas.bind("<Double-Button-1>", self.set_focus)
        self.canvas.bind("<Button-1>", self.set_cursor)
        self.canvas.bind("<Key>", self.handle_key)

        # add a few items to the canvas
        self.canvas.create_text(50, 50, text="insert your text")

    def set_font(self, font):
        self.font = font

    def highlight(self, item):
        # mark focused item.  note that this code recreates the
        # rectangle for each update, but that's fast enough for
        # this case.
        bbox = self.canvas.bbox(item)
        self.canvas.delete("highlight")
        if bbox:
            i = self.canvas.create_rectangle(
                bbox, fill="white",
                tag="highlight"
                )
            self.canvas.lower(i, item)

    def has_focus(self):
        #print('has focus \t {}'.format(self.canvas.focus()))
        return self.canvas.focus()

    def has_selection(self):
        # hack to work around bug in Tkinter 1.101 (Python 1.5.1)
        return self.canvas.tk.call(self.canvas._w, 'select', 'item')

    def set_focus(self, event):
        if self.canvas.type(tk.CURRENT) != "text":
            return

        self.highlight(tk.CURRENT)

        # move focus to item
        self.canvas.focus_set() # move focus to canvas
        self.canvas.focus(tk.CURRENT) # set focus to text item
        self.canvas.select_from(tk.CURRENT, 0)
        self.canvas.select_to(tk.CURRENT, 'end')

    def set_cursor(self, event):
        # move insertion cursor
        #print('set_cursor')
        item = self.has_focus()
        #print('item: ', item)
        if not item:
            return # or do something else

        # translate to the canvas coordinate system
        x = int(self.canvas.canvasx(event.x))
        y = int(self.canvas.canvasy(event.y))

        #print('x:  {}  y: {}'.format(x,y))

        self.canvas.icursor(item, "@{},{}".format(x, y))
        self.canvas.select_clear()

    def handle_key(self, event):
        # widget-wide key dispatcher
        item = self.has_focus()
        if not item:
            return

        insert = self.canvas.index(item, tk.INSERT)
        x = int(self.canvas.canvasx(event.x))
        y = int(self.canvas.canvasy(event.y))
        line = self.canvas.index(item, '@{},{}'.format(x,y))
        #print('x, y ', x,y)

        #if event.char >= " ":
        if event.char.isprintable():
            # printable character
            #print('printable: ', event.char.isprintable())
            if self.has_selection():
                self.canvas.dchars(item, tk.SEL_FIRST, tk.SEL_LAST)
                self.canvas.select_clear()
            self.canvas.insert(item, tk.INSERT, event.char)
            self.highlight(item)

        elif event.keysym == "BackSpace":
            #print('backspace')
            if self.has_selection():
                self.canvas.dchars(item, tk.SEL_FIRST, tk.SEL_LAST)
                self.canvas.select_clear()
            else:
                if insert > 0:
                    self.canvas.dchars(item, insert-1, insert)
            self.highlight(item)

        # navigation
        elif event.keysym == "Home":
            self.canvas.icursor(item, 0)
            self.canvas.select_clear()
        elif event.keysym == "End":
            self.canvas.icursor(item, 'end')
            self.canvas.select_clear()
        elif event.keysym == "Right":
            #print('right')
            self.canvas.icursor(item, insert+1)
            self.canvas.select_clear()
        elif event.keysym == "Left":
            self.canvas.icursor(item, insert-1)
            self.canvas.select_clear()
        elif event.keysym == "Return":
            self.canvas.insert(item, tk.INSERT, '\n')
            self.canvas.select_clear()

        else:
            pass # print event.keysym

# c = MyCanvas(tk.Tk())
# c.pack()
# c.mainloop()