def multiply(a,b):
    print("Will compute", a, "times", b)
    c = 0
    for i in range(0, a):
        c = c + b
    return c

import emb
def testemb():
    print("Number of arguments", emb.numargs())

