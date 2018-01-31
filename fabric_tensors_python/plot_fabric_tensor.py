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
import os
import sys
from fabric_tensor import *

def get_filename(png, tag=None):
    base = os.path.splitext(png)[0]
    if (tag == None):
        f = base+'.png'
    else:
        f = base+'_'+tag+'.png'
    return f

def set_axes_equal(ax):
    #from Karlo, https://stackoverflow.com/questions/13685386/matplotlib-equal-unit-length-with-equal-aspect-ratio-z-axis-is-not-equal-to
    '''Make axes of 3D plot have equal scale so that spheres appear as spheres,
    cubes as cubes, etc..  This is one possible solution to Matplotlib's
    ax.set_aspect('equal') and ax.axis('equal') not working for 3D.

    Input
      ax: a matplotlib axis, e.g., as output from plt.gca().
    '''

    x_limits = ax.get_xlim3d()
    y_limits = ax.get_ylim3d()
    z_limits = ax.get_zlim3d()

    x_range = abs(x_limits[1] - x_limits[0])
    x_middle = np.mean(x_limits)
    y_range = abs(y_limits[1] - y_limits[0])
    y_middle = np.mean(y_limits)
    z_range = abs(z_limits[1] - z_limits[0])
    z_middle = np.mean(z_limits)

    # The plot bounding box is a sphere in the sense of the infinity
    # norm, hence I call half the max range the plot radius.
    plot_radius = 0.5*max([x_range, y_range, z_range])

    ax.set_xlim3d([x_middle - plot_radius, x_middle + plot_radius])
    ax.set_ylim3d([y_middle - plot_radius, y_middle + plot_radius])
    ax.set_zlim3d([z_middle - plot_radius, z_middle + plot_radius])

def plot_3d(F, data, deform=1, plot='yes', png=None, tag=None):

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
    surf = ax.plot_surface(x, y, z,  rstride=1, cstride=1, facecolors=scalarMap.to_rgba(r), linewidth=0, antialiased=False, alpha=1.0)
    ax.autoscale()
    ax.set_aspect('equal')
    set_axes_equal(ax)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_zlabel('z')

    scalarMap.set_array(r)
    fig.colorbar(scalarMap)

    if tag != None:
        plt.title(tag) 

    if png != None:
        fig.savefig(get_filename(png,tag=tag), dpi=300)

    if plot == 'yes': 
        plt.show()

    return ax

def plot_3d_polar2d(F, data, deform=1, plot='yes', png=None, tag=None):

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

    if tag != None:
        plt.title(tag) 

    if png != None:
        fig.savefig(get_filename(png,tag=tag), dpi=300)

    if plot == 'yes': 
        plt.show()

    return ax

def plot_2d(F, data, deform=1, plot='yes', png=None, tag=None):

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
    surf = ax.plot(theta, r) #, 'r') 
    ax.autoscale()
    ax.set_xlabel(r'$\theta$')

    if tag != None:
        plt.title(tag) 

    if png != None:
        fig.savefig(get_filename(png,tag=tag), dpi=300)

    if plot == 'yes': 
        plt.show()

    return ax

def rose(data, z=None, ax=None, bins=30, bidirectional=True, color_by=np.mean, png=None, tag=None):
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
    if z is not None:
        idx = np.digitize(azimuths, edges)
        z = np.array([color_by(z[idx == i]) for i in range(1, idx.max() + 1)])
        z = np.ma.masked_invalid(z)
    cmap = plt.get_cmap('jet')
    coll = colored_bar(edges[:-1], counts/wSum, z=z, width=np.diff(edges), ax=ax, cmap=cmap)

    ax.set_aspect('equal')
    ax.autoscale()
    ax.set_xlabel(r'$\theta$')

    if tag != None:
        plt.title(tag) 

    if png != None:
        plt.savefig(get_filename(png,tag=tag), dpi=300)

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

def write_FT(fname, FT, format):
    np.save(fname+format, FT)
    return

def plot_FT(filename, dimension, weighted, plot, raw, png, write):
    N,F,D,p,data = calc_FT([filename], dimension, weighted)

    #unpack
    N0,N2,N4,N6 = N
    F0,F2,F4,F6 = F
    D0,D2,D4,D6 = D
    p2,p4 = p

    if (plot == 'yes'):
        if dimension == 2:
            if raw == 'yes':
                ax = plot_2d(F2, data, deform=1, plot='no', png=png, tag='F2')
                ax = plot_2d(F4, data, deform=1, plot='no', png=png, tag='F4')
                ax = plot_2d(F6, data, deform=1, plot='no', png=png, tag='F6')
                rose(data, ax=ax, bins=32, color_by='count', png=png, tag='rose')
            elif raw == 'no':
                plot_2d(F2, data, deform=1, png=png, tag='F2')
                plot_2d(F4, data, deform=1, png=png, tag='F4')
                plot_2d(F6, data, deform=1, png=png, tag='F6')
        elif dimension == 3:
            plot_3d(F2, data, deform=1, png=png, tag='F2')
            plot_3d(F4, data, deform=1, png=png, tag='F4')
            plot_3d(F6, data, deform=1, png=png, tag='F6')
            plot_3d(N2, data, deform=1, png=png, tag='N2')
            plot_3d(N4, data, deform=1, png=png, tag='N4')
            plot_3d(N6, data, deform=1, png=png, tag='N6')
            plot_3d_polar2d(F4, data, png=png, tag='polar')

    for thisWrite in write: 
        fname = thisWrite[0]
        format = thisWrite[1]
        if (format == 'F2'):
            write_FT(fname, F2, format)
        elif (format == 'F4'):
            write_FT(fname, F4, format)

    return 

if __name__ == "__main__":
    optlist,args = getopt.getopt(sys.argv[1:],'',longopts=['3D','3d','weighted','plot','raw','png=','writeF2=','writeF4='])
    dimension = 2
    weighted = 0
    plot = 'no'
    raw = 'no' 
    png = None
    write = [] 
    for item in optlist:
        if (item[0].lower() == '--3d'):
            dimension = 3 
        elif (item[0] == '--weighted'):
            weighted = 1
        elif (item[0] == '--plot'):
            plot = 'yes'
        elif (item[0] == '--raw'):
            raw = 'yes'
        elif (item[0] == '--png'):
            png = item[1]
        elif (item[0] == '--writeF2'):
            write.append( [item[1],'F2'] )
        elif (item[0] == '--writeF4'):
            write.append( [item[1],'F4'] )

    for filename in args:
        plot_FT(filename, dimension, weighted, plot, raw, png, write)
