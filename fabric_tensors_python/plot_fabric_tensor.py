#!/sw/bin/python2.7

import itertools
import math
import matplotlib
import matplotlib.cm as cm
import matplotlib.pyplot as plt
from matplotlib.collections import PatchCollection
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.patches import Rectangle
import numpy as np
import sys
from fabric_tensor import *

def plot_3d(F, data, deform=1, plot='yes'):

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

    if plot == 'yes': 
        plt.show()

    return ax

def plot_3d_polar2d(F, data, deform=1, plot='yes'):

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

    if plot == 'yes': 
        plt.show()

    return ax

def plot_2d(F, data, deform=1, plot='yes'):

    #create sampling 'mesh'
    nTheta = 720
    theta = np.linspace(0, 2*math.pi, nTheta+1)
    r = np.zeros( theta.shape )
    rad = np.ones( theta.shape )

    #evaluate FT at mesh
    for j in range(0, len(theta)):
        thisTheta = theta[j]
        vec = [ math.cos(thisTheta), math.sin(thisTheta)] 
        r[j] = evaluate_FT(F, vec)
            
    #deform mesh
    if (deform == 1):
        rad = np.multiply(rad, r)

    fig = plt.figure(1)
    ax = plt.subplot(111, projection='polar')
    ax.set_aspect('equal')
    surf = ax.plot(theta, r, 'r') 
    ax.autoscale()
    ax.set_xlabel(r'$\theta$')

    if plot == 'yes': 
        plt.show()

    return ax

def rose(data, z=None, ax=None, bins=30, bidirectional=True, color_by=np.mean):
    #adapted from Joe Kington: https://stackoverflow.com/questions/16264837/how-would-one-add-a-colorbar-to-this-example
    """Create a "rose" diagram (a.k.a. circular histogram).  

    Parameters:
    -----------
        azimuths: sequence of numbers
            The observed azimuths in degrees.
        z: sequence of numbers (optional)
            A second, co-located variable to color the plotted rectangles by.
        ax: a matplotlib Axes (optional)
            The axes to plot on. Defaults to the current axes.
        bins: int or sequence of numbers (optional)
            The number of bins or a sequence of bin edges to use.
        bidirectional: boolean (optional)
            Whether or not to treat the observed azimuths as bi-directional
            measurements (i.e. if True, 0 and 180 are identical).
        color_by: function or string (optional)
            A function to reduce the binned z values with. Alternately, if the
            string "count" is passed in, the displayed bars will be colored by
            their y-value (the number of azimuths measurements in that bin).
        Additional keyword arguments are passed on to PatchCollection.

    Returns:
    --------
        A matplotlib PatchCollection
    """

    #create arcs (define top of bin arc)
    bins = np.linspace(0, 2*math.pi, bins+1) #+ math.pi / bins

    azimuths = np.arctan2(data[:,1], data[:,0]) #note, this is right. It is arctan2(y,x) 
    weight = data[:,-1]
    wSum = np.sum(weight)
    print wSum 

    azimuths = np.asanyarray(azimuths)
    if color_by == 'count':
#        z = np.ones_like(azimuths)
        z = weight 
        color_by = np.sum
    if ax is None:
        fig = plt.figure(1)
        ax = plt.subplot(111, projection='polar')
    if bidirectional:
        other = azimuths + math.pi
        azimuths = np.concatenate([azimuths, other])
        weight = np.concatenate([weight, weight]) 
        if z is not None:
            z = np.concatenate([z, z])
    # Convert to 0-360, in case negative or >360 azimuths are passed in.
    azimuths[azimuths > math.pi*2] -= math.pi*2
    azimuths[azimuths < 0] += math.pi*2
    counts, edges = np.histogram(azimuths, range=[0, math.pi*2], bins=bins, weights=weight)
    print counts
    if z is not None:
        idx = np.digitize(azimuths, edges)
        z = np.array([color_by(z[idx == i]) for i in range(1, idx.max() + 1)])
        z = np.ma.masked_invalid(z)
    cmap = plt.get_cmap('jet')
    coll = colored_bar(edges[:-1], counts/wSum, z=z, width=np.diff(edges), ax=ax, cmap=cmap)

    ax.set_aspect('equal')
    ax.autoscale()
    ax.set_xlabel(r'$\theta$')

    plt.show()

    return coll

def colored_bar(left, height, z=None, width=0.8, bottom=0, ax=None, **kwargs):
    #from Joe Kington: https://stackoverflow.com/questions/16264837/how-would-one-add-a-colorbar-to-this-example
    """A bar plot colored by a scalar sequence."""
    if ax is None:
        ax = plt.gca()
    width = itertools.cycle(np.atleast_1d(width))
    bottom = itertools.cycle(np.atleast_1d(bottom))
    rects = []
    for x, y, h, w in zip(left, bottom, height, width):
        rects.append(Rectangle((x,y), w, h))
    coll = PatchCollection(rects, array=z, **kwargs)
    ax.add_collection(coll)
    ax.autoscale()
    return coll

def plot_FT(filename, dimension, weighted):
    N,F,D,p,data = calc_FT([filename], dimension, weighted)

    #unpack
    N0,N2,N4 = N
    F0,F2,F4 = F
    D0,D2,D4 = D
    p2,p4 = p

    if dimension == 2:
        ax = plot_2d(F4, data, deform=1, plot='no')
        rose(data, ax=ax, bins=32, color_by='count')
    elif dimension == 3:
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
