#!/sw/bin/python2.7

import getopt
import numpy as np
import sys

def read_file(filename):
    A = np.loadtxt(filename)
    #x,y,z, weight
    return A

def reduce_dimension(data):
    #reduce 3d data (x,y,z) into 2d data (r,z)
    #assumed independent dimension = z, reduced dimensions = x,y
    shape3d = data.shape
    shape2d = (shape3d[0], 3)    #r,z,w
    data2d = np.zeros(shape2d)
    assert(shape3d[1] == 3 or shape3d[1] == 4)

    for i in range(0, shape2d[0]):
        x = data[i,0]
        y = data[i,1]
        z = data[i,2]
        if (shape3d[1] == 3):
            w = 1.0
        elif (shape3d[1] == 4):
            w = data[i,3]
        r = np.sqrt( np.multiply(x,x) + np.multiply(y,y) ) 
        data2d[i,0] = r 
        data2d[i,1] = z 
        data2d[i,2] = w 
    return data2d 

def kronecker(delta_dimension, data_dimension):

    if (delta_dimension == 1):
        delta = 1

    elif (delta_dimension == 2):
        delta = np.zeros( (data_dimension, data_dimension) )
        for i in range(0, data_dimension):
            delta[i,i] = 1
            
    elif (delta_dimension == 3):
        delta = np.array( (data_dimension, data_dimension, data_dimension) )
        for i in range(0, data_dimension):
            delta[i,i,i] = 1

    elif (delta_dimension == 4):
        delta = np.ndarray( (data_dimension, data_dimension, data_dimension, data_dimension) )
        delta[:,:,:,:] = 0
        for i in range(0, data_dimension):
            delta[i,i,i,i] = 1

    return delta

def calculate_N(data, dimension, n):

    #N0
    N0 = 1

    #N2
    N2 = np.einsum('ai,aj->ij',data[:,0:dimension],data[:,0:dimension]) / n
    assert( abs(np.trace(N2) - 1.0) < 1e-4)

    #N4
    N4 = np.einsum('ai,aj,ak,al->ijkl',data[:,0:dimension],data[:,0:dimension],data[:,0:dimension],data[:,0:dimension]) / n
    assert( abs(np.trace(np.trace(N4)) - 1.0) < 1e-4)

    return N0, N2, N4

def calculate_F(N0, N2, N4, dimension, n):

    #F0
    F0 = N0

    #F2
    d2 = kronecker(2, dimension)
    F2 = 15.0/2.0 * (N2 - 1.0/5.0 * d2) #3d formula 
    assert( abs(np.trace(F2) - 3.0) < 1e-4)

    #F4
    dij_dkl = np.einsum('ij,kl->ijkl', d2, d2) 
    dij_N2kl = np.einsum('ij,kl->ijkl', d2, N2)
    F4 = 315.0/8.0 * (N4 - 2.0/3.0 * dij_N2kl + 1.0/21.0 * dij_dkl) #3d formula 

    return F0, F2, F4

def calculate_D(N0, N2, N4, dimension, n):

    #D0
    D0 = N0

    #F2
    d2 = kronecker(2, dimension)
    D2 = 15.0/2.0 * (N2 - 1.0/3.0 * d2) #3d formula 
    assert( abs(np.trace(D2)) < 1e-4)

    #F4
    dij_dkl = np.einsum('ij,kl->ijkl', d2, d2) 
    dij_N2kl = np.einsum('ij,kl->ijkl', d2, N2)
    D4 = 315.0/8.0 * (N4 - 6.0/7.0 * dij_N2kl + 3.0/35.0 * dij_dkl) #3d formula 

    return D0, D2, D4

def calc_statistical_significance(D2, D4):
    return

def calc_FT(files, dimension, weighted):
    for filename in files:
        print filename
        data = read_file(filename)

        assert( data.shape[1] == 4 )

        if (dimension == 2):
            print "*Reducing data dimension"
            data = reduce_dimension(data)

        n = data.shape[0]
        assert( data.shape[1] == dimension + 1 )

        #calculate fabric tensors of first kind (moment tensors, N)
        N0, N2, N4 = calculate_N(data, dimension, n)
        #calculate fabric tensors of first kind (fabric tensors, F)
        F0, F2, F4 = calculate_F(N0, N2, N4, dimension, n)
        #calculate fabric tensors of first kind (deviator tensors, D)
        D0, D2, D4 = calculate_D(N0, N2, N4, dimension, n)

#        print "N2 = ",N2
#        print "F2 = ",F2
#        print "D2 = ",D2

        #calculate statistical significance
        calc_statistical_significance(D2, D4) 
 
    return N0,N2,N4, F0,F2,F4, D0,D2,D4


if __name__ == "__main__":
    optlist,args = getopt.getopt(sys.argv[1:],'',longopts=['3D','3d','weighted'])
    dimension = 2
    weighted = 0
    for item in optlist:
        if (item[0].lower() == '--3d'):
            dimension = 3 
        elif (item[0] == '--weighted'):
            weighted = 1
    tag = ''
    calc_FT(args, dimension, weighted)
