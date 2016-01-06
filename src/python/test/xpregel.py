import cloudpickle
import pickle

class base():

    def __init__(self):
        pass

    def save(self):
        pickled_compute = cloudpickle.dumps(self.compute)
        pickled_aggregate = cloudpickle.dumps(self.aggregate)
        pickled_end = cloudpickle.dumps(self.end)
        f = open('_xpregel_closure.bin', 'wb')
        pickle.dump((pickled_compute, pickled_aggregate, pickled_end), f)
        f.close()
        
    def run(self):
        self.save()
