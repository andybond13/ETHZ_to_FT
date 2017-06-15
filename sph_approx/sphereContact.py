import os
import math
import sys

#run: python sphereContact.py *.txt

def writeContacts(outfile, idpair, unitvec,radpair,delta,area):
    with open(outfile,'w') as f:
        for i in range(0, len(idpair)):
            f.write('{} {} {} {} {} {} {} {} {}\n'.format(idpair[i][0], idpair[i][1], unitvec[i][0], unitvec[i][1], unitvec[i][2], radpair[i][0], radpair[i][1], delta[i], area[i]) )
    return

def calcDistance(cI, cJ):
    xI = cI[0]
    yI = cI[1]
    zI = cI[2]
    xJ = cJ[0]
    yJ = cJ[1]
    zJ = cJ[2]

    dist = math.sqrt( (xI-xJ)*(xI-xJ) + (yI-yJ)*(yI-yJ) + (zI-zJ)*(zI-zJ) )

    return dist

def findContacts(ids, rads, centroids):
    idpairs = []
    unitvecs = []
    areas = []
    deltas = []
    radpairs = []

    for i in range(0, len(ids)-1):
        idxI = ids[i]
        rI = rads[i]

        for j in range(i+1, len(ids)):
            idxJ = ids[j]
            rJ = rads[j]
             
            dist = calcDistance(centroids[i], centroids[j])
    
            if (rI + rJ >= dist):
                xI = centroids[i][0]
                yI = centroids[i][1]
                zI = centroids[i][2]
                xJ = centroids[j][0]
                yJ = centroids[j][1]
                zJ = centroids[j][2]
 
                vec = [xI-xJ, yI-yJ, zI-zJ]
                norm = math.sqrt( vec[0]*vec[0] + vec[1]*vec[1] + vec[2]*vec[2] )
                unitvec = [vec[0]/norm, vec[1]/norm, vec[2]/norm]
                delta = rI + rJ - dist
                R = 1.0 / (1.0/rI + 1.0/rJ)
                a = math.sqrt(R * delta)
                area = math.pi * a * a

                idpairs.append([idxI, idxJ])
                unitvecs.append(unitvec)
                areas.append(area)
                deltas.append(delta)
                radpairs.append([rI, rJ])         

    return idpairs,unitvecs,areas,deltas,radpairs

def readFile(file):
    ids = []
    rads = []
    centroids = []
    lineNum = 0
    with open(file,'r') as f:
        for line in f:
            lineNum += 1
#            print lineNum,line 
            if lineNum == 1:
                continue

            ls = line.strip().split(',')
            id = int(ls[0])
            vol = float(ls[1])
            xc = float(ls[8])
            yc = float(ls[9])
            zc = float(ls[10])
            
            rad = math.pow(vol*3.0/4.0, 1.0/3.0)
            
            ids.append(id)
            rads.append(rad)
            centroids.append([xc, yc, zc])
    return ids, rads, centroids

def main(files,tag):
    for file in files:
        base = os.path.basename(file)
        outfile = '.'.join(base.split('.')[:-1])+tag+'.out'
        id,rad,centroid=readFile(file)

        idpair,unitvec,area,delta,radpair = findContacts(id, rad, centroid)
        writeContacts(outfile, idpair, unitvec, radpair, delta, area) 
    return

tag = ''
files = sys.argv[1:]
main(files,tag)
