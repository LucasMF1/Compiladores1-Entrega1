
import numpy
import pandas as p


def funcaoQualquer(a,b,c):
    print(a,b,c)
    a = b + c
    a = b * c
    a = b / c
    d = [a,b,c]
    e = {
        "qualquer":c
    }

    d.append(2)

    d.remove(2)

    e["qualquer"] = 2

    try:
        raise Exception()
    except:
        pass

    match a:
        case 1:
            pass
        case 2:
            pass
        case b:
            pass

    if a > b:
        pass

    if a == b:
        pass

    if a != b:
        pass

    if a not in d:
        pass

    if a != None:
        pass
    
    a += 2
    a -= 2
    a *= 2
    a /= 2

    while b > c:
        break

    for i in range(b):
        break

    

