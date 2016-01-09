import cloudpickle
import pickle

class base():

    def __init__(self):
        pass

    def save(self):
        pickled_compute = cloudpickle.dumps(self.compute)
        pickled_aggregator = cloudpickle.dumps(self.aggregator)
        pickled_terminator = cloudpickle.dumps(self.terminator)
        f = open('_xpregel_closure.bin', 'wb')
        pickle.dump((pickled_compute, pickled_aggregator, pickled_terminator), f)
        f.close()
        
    def run(self):
        self.save()
