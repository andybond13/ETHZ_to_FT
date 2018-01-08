#!/sw/bin/python2.7

import getopt
import numpy as np
import sys

def read_file(filename):
    A = np.loadtxt(filename)
    #x,y,z, weight
    return A 

def calc_FT(files, dimension, weighted):
    for filename in files:
        print filename
        data = read_file(filename)
        print data
    return

if __name__ == "__main__":
    optlist,args = getopt.getopt(sys.argv[1:],'',longopts=['3D','weighted'])
    dimension = 2
    weighted = 0
    for item in optlist:
        if (item[0] == '--3D'):
            dimension = 3 
        elif (item[0] == '--weighted'):
            weighted = 1
    tag = ''
    calc_FT(args, dimension, weighted)
