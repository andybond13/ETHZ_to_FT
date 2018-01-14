#!/sw/bin/python2.7

import getopt
import math
import numpy as np
from scipy.stats import chi2
import sys

def read_file(filename):
    A = np.loadtxt(filename)
    #x,y,z, weight
    return A

def evaluate_FT(FT, vec):
    if isinstance(FT, int):
        return 1
    elif ( len(FT.shape) == 2):
        return np.einsum('ij,i,j->',FT,vec,vec)
    elif ( len(FT.shape) == 4):
        return np.einsum('ijkl,i,j,k,l->',FT,vec,vec,vec,vec)

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

    weight = data[:,dimension] 
    wSum = np.sum(weight)
    assert(wSum > 0)

    if (all(weight == 1.0)):
        assert(wSum == n)

    #N0
    N0 = 1

    #N2
    N2 = np.einsum('ai,aj,a->ij',data[:,0:dimension],data[:,0:dimension],weight) / wSum
    assert( abs(np.trace(N2) - 1.0) < 1e-4)

    #N4
    N4 = np.einsum('ai,aj,ak,al,a->ijkl',data[:,0:dimension],data[:,0:dimension],data[:,0:dimension],data[:,0:dimension],weight) / wSum
    assert( abs(np.trace(np.trace(N4)) - 1.0) < 1e-4)

    return N0, N2, N4

def calculate_F(N0, N2, N4, dimension, n):

    #F0
    F0 = N0

    #F2
    d2 = kronecker(2, dimension)
    if (dimension == 3):
        F2 = 15.0/2.0 * (N2 - 1.0/5.0 * d2)
    elif (dimension == 2):
        F2 = 4.0 * (N2 - 1.0/4.0 * d2)
    assert( abs(np.trace(F2) - dimension) < 1e-4)

    #F4
    dij_dkl = np.einsum('ij,kl->ijkl', d2, d2) 
    dij_N2kl = np.einsum('ij,kl->ijkl', d2, N2)
    if (dimension == 3):
        F4 = 315.0/8.0 * (N4 - 2.0/3.0 * dij_N2kl + 1.0/21.0 * dij_dkl)
    elif (dimension == 2):
        F4 = 16.0 * (N4 - 3.0/4.0 * dij_N2kl + 1.0/16.0 * dij_dkl)

    return F0, F2, F4

def calculate_D(N0, N2, N4, dimension, n):

    #D0
    D0 = N0

    #F2
    d2 = kronecker(2, dimension)
    if (dimension == 3): 
        D2 = 15.0/2.0 * (N2 - 1.0/3.0 * d2)
    elif (dimension == 2): 
        D2 = 4.0 * (N2 - 1.0/2.0 * d2)
    assert( abs(np.trace(D2)) < 1e-4)

    #F4
    dij_dkl = np.einsum('ij,kl->ijkl', d2, d2) 
    dij_N2kl = np.einsum('ij,kl->ijkl', d2, N2)
    if (dimension == 3): 
        D4 = 315.0/8.0 * (N4 - 6.0/7.0 * dij_N2kl + 3.0/35.0 * dij_dkl)
    elif (dimension == 2): 
        D4 = 16.0 * (N4 - dij_N2kl + 1.0/8.0 * dij_dkl)

    return D0, D2, D4

def calc_statistical_significance(D2, D4, dimension, n):

    if (dimension == 3):
        Dij_Dij = np.einsum('ij,ij->', D2, D2)
        stat2 = 2.0*n/15.0 * Dij_Dij
        p2 = chi2.cdf(stat2, 5)

        Dijkl_Dijkl = np.einsum('ijkl,ijkl->', D4, D4)
        Dijkl_Dijkm_Dlm = np.einsum('ijkl,ijkm,lm->', D4, D4, D2)
        stat4 = 8.0*n/315.0 * (Dijkl_Dijkl - 8.0/11.0*Dijkl_Dijkm_Dlm)
        p4 = chi2.cdf(stat4, 9)
 
    elif (dimension == 2):
        Dij_Dij = np.einsum('ij,ij->', D2, D2)
        stat2 = n/4.0 * Dij_Dij
        p2 = chi2.cdf(stat2, 2)

        Dijkl_Dijkl = np.einsum('ijkl,ijkl->', D4, D4)
        stat4 = n/16.0 * Dijkl_Dijkl
        p4 = chi2.cdf(stat4, 2)

    #p-values: closer to 1 = more significant. Desire > 95,99,99.5% significance.
    print "F/D2 Statistic: {}, P-Value = {}".format(stat2, p2) 
    print "F/D4 Statistic: {}, P-Value = {}".format(stat4, p4) 
    
    return p2,p4

def calc_fractional_anisotropy(F2, dimension):

    eigs = np.linalg.eigvals(F2)

    if (dimension == 2):
        a = np.max(eigs) 
        b = np.min(eigs) 
        FA = math.sqrt(1.0 - (b*b)/(a*a)) 

    elif (dimension == 3):
        e0 = eigs[0]
        e1 = eigs[1]
        e2 = eigs[2]
        num = math.sqrt( math.pow(e0-e1,2) + math.pow(e1-e2,2) + math.pow(e2-e0,2) )
        denom = 2.0 * math.sqrt( e0*e0 + e1*e1 + e2*e2 )
        FA = num/denom 

    print "Fractional Anisotropy = {}".format(FA)

    return FA

def calc_FT(files, dimension, weighted):
    for filename in files:
        print filename
        data = read_file(filename)

        n = data.shape[0]

        if (data.shape[1] == dimension):
            #add weight
            data = np.append(data, np.ones((n,1)), 1)
        assert( data.shape[1] == dimension + 1 )

        #calculate fabric tensors of first kind (moment tensors, N)
        N0, N2, N4 = calculate_N(data, dimension, n)
        N = [N0, N2, N4]
        #calculate fabric tensors of first kind (fabric tensors, F)
        F0, F2, F4 = calculate_F(N0, N2, N4, dimension, n)
        F = [F0, F2, F4]
        #calculate fabric tensors of first kind (deviator tensors, D)
        D0, D2, D4 = calculate_D(N0, N2, N4, dimension, n)
        D = [D0, D2, D4]

#        print "N2 = ",N2
#        print "F2 = ",F2
#        print "D2 = ",D2

        #calculate statistical significance
        p2,p4 = calc_statistical_significance(D2, D4, dimension, n)
        p = [p2,p4]

        FA = calc_fractional_anisotropy(F2, dimension) 
 
    return N, F, D, p, data


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
