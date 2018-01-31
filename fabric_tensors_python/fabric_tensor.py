#!/sw/bin/python2.7

import getopt
import math
import numpy as np
from scipy.stats import chi2
from sympy.utilities.iterables import multiset_permutations
import sys

def read_file(filename):
    A = np.loadtxt(filename)
    #x,y,z, weight
    return A

def tensor_to_vector(T):
    #Voigt notation: represent higher-order tensor as matrix, using (assumed) symmetries

    dimension = T.shape[0]
    order = len(T.shape) 

    if (order == 2):
        #2nd-rank tensor
        if (dimension == 2):
            vec = np.zeros( (3,1) )
            vec[0,0] = T[0,0]
            vec[1,0] = T[1,1]
            vec[2,0] = (T[0,1] + T[1,0]) * math.sqrt(0.5)
        elif (dimension == 3):
            vec = np.zeros( (6,1) )
            vec[0,0] = T[0,0]
            vec[1,0] = T[1,1]
            vec[2,0] = T[2,2]
            vec[3,0] = (T[1,2] + T[1,2]) * math.sqrt(0.5)
            vec[4,0] = (T[0,2] + T[2,0]) * math.sqrt(0.5)
            vec[5,0] = (T[0,1] + T[1,0]) * math.sqrt(0.5)
        else:
            print "Tensor of order {}, dimension {} not supported".format(order, dimension)
    elif (order == 4):
        #4th-rank tensor
        if (dimension == 2):
            vec = np.zeros( (3,3) )
            vec[0,0] = T[0,0,0,0]
            vec[0,1] = T[0,0,1,1]
            vec[1,0] = T[1,1,0,0]
            vec[1,1] = T[1,1,1,1]
            vec[2,0] = (T[0,1,0,0] + T[1,0,0,0]) * math.sqrt(0.5)
            vec[2,1] = (T[0,1,1,1] + T[1,0,1,1]) * math.sqrt(0.5)
            vec[0,2] = (T[0,0,0,1] + T[0,0,1,0]) * math.sqrt(0.5)
            vec[1,2] = (T[1,1,0,1] + T[1,1,0,1]) * math.sqrt(0.5)
            vec[2,2] = (T[0,1,0,1] + T[1,0,1,0] + T[0,1,1,0] + T[1,0,0,1]) * 0.5
        elif (dimension == 3):
            vec = np.zeros( (6,6) )
            for i in range(0,3):
                for j in range(0,3):
                    vec[j,i] = T[j,j,i,i]
                vec[3,i] = (T[1,2,i,i] + T[2,1,i,i]) * math.sqrt(0.5) 
                vec[4,i] = (T[0,2,i,i] + T[2,0,i,i]) * math.sqrt(0.5) 
                vec[5,i] = (T[0,1,i,i] + T[1,0,i,i]) * math.sqrt(0.5) 
                vec[i,3] = (T[i,i,1,2] + T[i,i,2,1]) * math.sqrt(0.5) 
                vec[i,4] = (T[i,i,0,2] + T[i,i,2,0]) * math.sqrt(0.5) 
                vec[i,5] = (T[i,i,0,1] + T[i,i,1,0]) * math.sqrt(0.5)
            vec[3,3] = (T[1,2,1,2] + T[1,2,2,1] + T[2,1,1,2] + T[2,1,2,1]) * 0.5 
            vec[4,4] = (T[0,2,0,2] + T[0,2,2,0] + T[2,0,0,2] + T[2,0,2,0]) * 0.5 
            vec[5,5] = (T[0,1,0,1] + T[0,1,1,0] + T[1,0,0,1] + T[1,0,1,0]) * 0.5 
            vec[4,3] = (T[0,2,1,2] + T[0,2,2,1] + T[2,0,1,2] + T[2,0,2,1]) * 0.5 
            vec[3,4] = (T[1,2,0,2] + T[1,2,2,0] + T[2,1,0,2] + T[2,1,2,0]) * 0.5 
            vec[5,3] = (T[0,1,1,2] + T[0,1,2,1] + T[1,0,1,2] + T[1,0,2,1]) * 0.5 
            vec[3,5] = (T[1,2,0,1] + T[1,2,1,0] + T[2,1,0,1] + T[2,1,1,0]) * 0.5 
            vec[5,4] = (T[0,1,0,2] + T[0,1,2,0] + T[1,0,0,2] + T[1,0,2,0]) * 0.5 
            vec[4,5] = (T[0,2,0,1] + T[0,2,1,0] + T[2,0,0,1] + T[2,0,1,0]) * 0.5 
        else:
            print "Tensor of order {}, dimension {} not supported".format(order, dimension)
    else:
        print "Tensor of order {} not supported".format(order)
        assert(1 == 0)

    return vec    

def evaluate_FT(FT, vec):
    if isinstance(FT, int):
        return 1
    elif ( len(FT.shape) == 2):
        return np.einsum('ij,i,j->',FT,vec,vec)
    elif ( len(FT.shape) == 4):
        return np.einsum('ijkl,i,j,k,l->',FT,vec,vec,vec,vec)
    elif ( len(FT.shape) == 6):
        return np.einsum('ijklmn,i,j,k,l,m,n->',FT,vec,vec,vec,vec,vec,vec)

def symmetrize(T):
    order = len(T.shape) 
    if order == 1:
        key = 'i'
    elif order == 2:
        key = 'ij'
    elif order == 3:
        key = 'ijk'
    elif order == 4:
        key = 'ijkl'
    elif order == 6:
        key = 'ijklmn'
    numCombos = math.factorial(order)

    Tsym = np.zeros( T.shape )
    permutations = []
    for i in multiset_permutations(key):
        combo = ''.join(i)+'->'+key
        permutations.append(combo)
        Tsym += 1.0/float(numCombos) * np.einsum(combo, T)

    assert( len(permutations) == numCombos )
    return Tsym

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

    #N6
    N6 = np.einsum('ai,aj,ak,al,am,an,a->ijklmn',data[:,0:dimension],data[:,0:dimension],data[:,0:dimension],data[:,0:dimension],data[:,0:dimension],data[:,0:dimension],weight) / wSum
    assert( abs(np.trace(np.trace(np.trace(N6))) - 1.0) < 1e-4)

    return N0, N2, N4, N6

def calculate_F(N0, N2, N4, N6, dimension, n):

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
    dij_dkl = symmetrize( np.einsum('ij,kl->ijkl', d2, d2) )
    dij_N2kl = symmetrize( np.einsum('ij,kl->ijkl', d2, N2) )
    if (dimension == 3):
        F4 = 315.0/8.0 * (N4 - 2.0/3.0 * dij_N2kl + 1.0/21.0 * dij_dkl)
    elif (dimension == 2):
        F4 = 16.0 * (N4 - 3.0/4.0 * dij_N2kl + 1.0/16.0 * dij_dkl)

    #F6
    dij_dkl_dmn = symmetrize( np.einsum('ij,kl,mn->ijklmn', d2, d2, d2) )
    dij_dkl_N2mn = symmetrize( np.einsum('ij,kl,mn->ijklmn', d2, d2, N2) )
    dij_N4klmn = symmetrize( np.einsum('ij,klmn->ijklmn', d2, N4) )
    if (dimension == 3):
        F6 = 3003.0/16.0 * (N6 - 15.0/13.0 * dij_N4klmn + 45.0/143.0 * dij_dkl_N2mn - 5.0/429.0 * dij_dkl_dmn)
    elif (dimension == 2):
        F6 = 64.0 * (N6 - 5.0/4.0 * dij_N4klmn + 3.0/8.0 * dij_dkl_N2mn - 1.0/64.0 * dij_dkl_dmn)

    return F0, F2, F4, F6

def calculate_D(N0, N2, N4, N6, dimension, n):

    #D0
    D0 = N0

    #D2
    d2 = kronecker(2, dimension)
    if (dimension == 3): 
        D2 = 15.0/2.0 * (N2 - 1.0/3.0 * d2)
    elif (dimension == 2): 
        D2 = 4.0 * (N2 - 1.0/2.0 * d2)
    assert( abs(np.trace(D2)) < 1e-4)

    #D4
    dij_dkl = symmetrize( np.einsum('ij,kl->ijkl', d2, d2) ) 
    dij_N2kl = symmetrize( np.einsum('ij,kl->ijkl', d2, N2) )
    if (dimension == 3): 
        D4 = 315.0/8.0 * (N4 - 6.0/7.0 * dij_N2kl + 3.0/35.0 * dij_dkl)
    elif (dimension == 2): 
        D4 = 16.0 * (N4 - dij_N2kl + 1.0/8.0 * dij_dkl)

    #D6
    dij_dkl_dmn = symmetrize( np.einsum('ij,kl,mn->ijklmn', d2, d2, d2) )
    dij_dkl_N2mn = symmetrize( np.einsum('ij,kl,mn->ijklmn', d2, d2, N2) )
    dij_N4klmn = symmetrize( np.einsum('ij,klmn->ijklmn', d2, N4) )
    if (dimension == 3):
        D6 = 3003.0/16.0 * (N6 - 15.0/11.0 * dij_N4klmn + 5.0/11.0 * dij_dkl_N2mn - 5.0/231.0 * dij_dkl_dmn)
    elif (dimension == 2):
        D6 = 64.0 * (N6 - 3.0/2.0 * dij_N4klmn + 9.0/16.0 * dij_dkl_N2mn - 1.0/32.0 * dij_dkl_dmn)

    return D0, D2, D4, D6

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
    print "--- Statistical Significance: desire >90%"
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

def check_symmetric(a, tol=1e-8):
    #stackoverflow.com/questions/42908334
#    return np.allclose(a, a.T, atol=tol)
    return np.allclose(a, symmetrize(a), atol=tol)

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
        N0, N2, N4, N6 = calculate_N(data, dimension, n)
        N = [N0, N2, N4, N6]
        #calculate fabric tensors of first kind (fabric tensors, F)
        F0, F2, F4, F6 = calculate_F(N0, N2, N4, N6, dimension, n)
        F = [F0, F2, F4, F6]
        #calculate fabric tensors of first kind (deviator tensors, D)
        D0, D2, D4, D6 = calculate_D(N0, N2, N4, N6, dimension, n)
        D = [D0, D2, D4, D6]

#        print "N2 = ",N2
#        print "N2 vec = ",tensor_to_vector(N2)
#        print "F2 = ",F2
#        print "F2 vec = ",tensor_to_vector(F2)
#        print "D2 = ",D2
#        print "D2 vec = ",tensor_to_vector(D2)
#        print "N4 = ",N4
#        print "N4 vec = ",tensor_to_vector(N4)
#        print "F4 = ",F4
#        print "F4 vec = ",tensor_to_vector(F4)
#        print "D4 = ",D4
#        print "D4 vec = ",tensor_to_vector(D4)
        assert( check_symmetric( N2 ) ) 
        assert( check_symmetric( F2 ) ) 
        assert( check_symmetric( D2 ) ) 
        assert( check_symmetric( tensor_to_vector(N4) ) )
        assert( check_symmetric( tensor_to_vector(F4) ) )
        assert( check_symmetric( tensor_to_vector(D4) ) )
        assert( check_symmetric( N4 ) ) 
        assert( check_symmetric( F4 ) ) 
        assert( check_symmetric( D4 ) ) 
        assert( check_symmetric( N6 ) ) 
        assert( check_symmetric( F6 ) ) 
        assert( check_symmetric( D6 ) ) 

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
