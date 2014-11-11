def createGenerator():
   mylist = range(3)
   for i in mylist:
       yield i*i

def createGenerator2():
   mylist = range(3)
   if False:
       yield 3

def createGenerator3():
    yield 3
    yield 9
    yield 11

