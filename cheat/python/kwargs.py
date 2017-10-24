
def junk1(x, **kwargs):
    #kwargs['pistol'] = kwargs.get('pistol', 'rat')
    if 'pistol' not in kwargs: kwargs['pistol'] = 'rat'
    return junk2(3, **kwargs)

def junk2(y, **kwargs):

    print("y is {}".format(y))
    for key, value in kwargs.items():
        print("kwargs['{}'] is {}".format(key, value))

    return [len(s) for s in kwargs.keys()]

#print( junk1(17, pistol='rainbow', book='skunk', rod='bat', tank='bird') )
print( junk1(17, book='skunk', rod='bat', tank='bird') )

