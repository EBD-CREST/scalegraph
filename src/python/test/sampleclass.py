import cloudpickle
import pickle


class base():
    def __init__(self):
        self.value = 123
        self.arg = 999
        
    def printvalue(self, arg):
        print("called base::printvalue")

    def worker(self, func):
        self.value = 345;
        task = pickle.loads(func)
        for i in range(100,105):
            self.value = i
            task(self, i)
        
    def run(self):
        self.value = 666;
        pickled_function = cloudpickle.dumps(global printvalue)
        self.worker(pickled_function)

class pagerank(base):
    def printvalue(self, arg):
        print(self.value)
        print(arg)


if __name__ == '__main__':
    print("hogehoge")
    pr = pagerank()
    pr.run()
