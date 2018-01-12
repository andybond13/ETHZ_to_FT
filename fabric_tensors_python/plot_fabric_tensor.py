#!/sw/bin/python2.7

import math
import matplotlib
import matplotlib.cm as cm
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np
import sys
from fabric_tensor import *

def plot_3d(F, data, deform=1):

    #create sampling 'mesh'
    nTheta = 144
    theta = np.linspace(0, 2*math.pi, nTheta+1)
    nPhi = 72
    phi = np.linspace(0, math.pi, nPhi+1)
    phi, theta = np.meshgrid(phi, theta)
    x = np.sin(phi) * np.cos(theta)
    y = np.sin(phi) * np.sin(theta)
    z = np.cos(phi)

    #evaluate FT at mesh
    r = np.zeros( x.shape )
    for i in range(0, x.shape[0]):
        for j in range(0, x.shape[1]):
            vec = [x[i,j], y[i,j], z[i,j]]
            r[i,j] = evaluate_FT(F, vec)

    #deform mesh
    if (deform == 1):
        x = np.multiply(x, r)
        y = np.multiply(y, r)
        z = np.multiply(z, r)

    #normalize colors
    cNorm = matplotlib.colors.Normalize(vmin = np.amin(r), vmax = np.amax(r))
    scalarMap = cm.ScalarMappable(cmap='jet', norm=cNorm) 

    fig = plt.figure(1)
    ax = plt.subplot(111, projection='3d')
    ax.set_aspect('equal')
    surf = ax.plot_surface(x, y, z,  rstride=1, cstride=1, facecolors=scalarMap.to_rgba(r), linewidth=0, antialiased=False, alpha=1.0)
    ax.autoscale()
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_zlabel('z')

    scalarMap.set_array(r)
    fig.colorbar(scalarMap) 
    plt.show()

    return

def plot_3d_polar2d(F, data, deform=1):

    #create sampling 'mesh'
    nTheta = 144
    theta = np.linspace(0, 2*math.pi, nTheta+1)
    nPhi = 72
    phi = np.linspace(0, math.pi, nPhi+1)
    z = np.cos(phi)
    rad = np.sqrt( 1 - np.multiply(z, z) )

    #evaluate FT at mesh
    r = np.zeros( phi.shape )
    for i in range(0, len(phi)):
        thisPhi = phi[i]
        val = 0
        #average values around the theta direction
        for j in range(0, len(theta)):
            thisTheta = theta[j]
            vec = [ math.sin(thisPhi) * math.cos(thisTheta), math.sin(thisPhi) * math.sin(thisTheta), math.cos(thisPhi)] 
            val += evaluate_FT(F, vec)
        r[i] = val / len(theta)
            
    #deform mesh
    if (deform == 1):
        rad = np.multiply(rad, r)
        z = np.multiply(z, r)

    fig = plt.figure(1)
    #ax = plt.subplot(111)
    ax = plt.subplot(111, projection='polar')
    ax.set_aspect('equal')
    #surf = ax.plot(rad, z, 'r') 
    surf = ax.plot(phi, r, 'r') 
    ax.set_theta_direction(-1)
    ax.set_theta_zero_location('N')
    ax.autoscale()
    ax.set_xlabel(r'$\phi$')

    plt.show()

    return

def plot_2d():
    #Plot
    r = np.zeros( len(theta) )
    for i in range(0, len(r)):
        angle = theta[i]
        vec = [math.cos(angle), math.sin(angle)]
        r[i] = evaluate_FT(F2, vec)
    fig = plt.figure(1)
    ax = plt.subplot(111, projection='polar')
    ax.plot(theta, r)
    #raw vec plot (2D only -- replace with bar chart rose plot)
    nSample = 1000
    for i in range(0, nSample): #data.shape[0]):
        vec = data[i,:]
        angle = np.arctan2(vec[0], vec[1]) 
        ax.plot( (0,angle), (0,1) , 'k', alpha=1.0/math.sqrt(nSample))
        ax.plot( (0,angle+math.pi), (0,1) , 'k', alpha=1.0/math.sqrt(nSample))
    ax.grid(True)

    ax.set_rmax(2)
#    ax.set_rticks([0.5, 1, 1.5, 2])  # less radial ticks
    ax.set_rlabel_position(-22.5)  # get radial labels away from plotted line
    ax.grid(True)
    ax.autoscale()
    plt.show()

    return

def plot_FT(filename, dimension, weighted):
    N,F,D,p,data = calc_FT([filename], dimension, weighted)

    #unpack
    N0,N2,N4 = N
    F0,F2,F4 = F
    D0,D2,D4 = D
    p2,p4 = p

    plot_3d(F4, data, deform=1)
    plot_3d_polar2d(F4, data)

    return 

if __name__ == "__main__":
    optlist,args = getopt.getopt(sys.argv[1:],'',longopts=['3D','3d','weighted'])
    dimension = 2
    weighted = 0
    for item in optlist:
        if (item[0].lower() == '--3d'):
            dimension = 3 
        elif (item[0] == '--weighted'):
            weighted = 1

    for filename in args:
        plot_FT(filename, dimension, weighted)
