from threading import Timer

class RepeatTimer(Timer):

    def run(self):
        while not self.finished.wait(self.interval):
            self.function(*self.args, **self.kwargs)

val = 1000

def f(msg):
    global val
    val -= 1
    print('msg', msg)
    print('val', val)


timer = RepeatTimer(0.5, f, args=(val, ))
timer.start()
