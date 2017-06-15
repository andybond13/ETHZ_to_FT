#!/usr/bin/python

import math
import re
import sys


def processLine(line):
#ITEM: ATOMS id type type x y z ix iy iz vx vy vz fx fy fz omegax omegay omegaz radius
	line = line.split()
	x = line[3]
	y = line[4]
	z = line[5]
	r = line[18]
	#print x,y,z,r
	out = [x,y,z,r]
	return out

def readFile(filename):

	#print "filename = ",filename
	filename = "./"+filename
	file = open(filename, 'r')

	data = []
	atoms = 0

	flag = 0
	for line in file:
		line = line.strip()
		if (flag == 1):
			atoms += 1
			data.append(processLine(line))
		if (line[0:11] == "ITEM: ATOMS"):
			flag = 1
	return data,atoms

def findBoxAndVolume(data):

	xmin = -0.017
	xmax = 0.017
	ymin = -0.017
	ymax = 0.017
	zmin = 0.0
	zmax = 0.0
	vol = 0.0

	xminalt = 0.0
	xmaxalt = 0.0
	yminalt = 0.0
	ymaxalt = 0.0
	zminalt = 0.0

	for line in data:
		#x,y,z,r
		x = float(line[0])
		y = float(line[1])
		z = float(line[2])
		r = float(line[3])

		if (z+r > zmax):
			zmax = z+r

		if (z-r < zminalt):
			zminalt = z-r

		if (x-r < xminalt):
			xminalt = x-r

		if (x+r > xmaxalt):
			xmaxalt = x+r

		if (y-r < yminalt):
			yminalt = y-r

		if (y+r > ymaxalt):
			ymaxalt = y+r

		vol += math.pi * 4/3 * r * r * r

	out = [xmin,xmax,ymin,ymax,zmin,zmax,vol,xminalt,xmaxalt,yminalt,ymaxalt,zminalt]
	return out

def volFrac(box):
	#xmin,xmax,ymin,ymax,zmin,zmax,vol
	xmin = box[0]
	xmax = box[1]
	ymin = box[2]
	ymax = box[3]
	zmin = box[4]
	zmax = box[5]
	vol = box[6]
	xminalt = box[7]
	xmaxalt = box[8]
	yminalt = box[9]
	ymaxalt = box[10]
	zminalt = box[11]

	volbox = (xmax - xmin) * (ymax - ymin) * (zmax - zmin)
	volboxalt = (xmaxalt - xminalt) * (ymaxalt - yminalt) * (zmax - zminalt)

	
	if (volbox > 0):
		vf1 = vol/volbox
	else:
		vf1 = 0

	if (volboxalt > 0):
		vf2 = vol/volboxalt
	else:
		vf2 = 0

	return vf1,vf2

def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)

def main():

	print 'Number of arguments:', len(sys.argv), 'arguments.'
	print 'Argument List:', str(sys.argv)

	list = sys.argv[1:]
	list = natural_sort(list)
		
	for file in list:
		data,atoms = readFile(file)

		box = findBoxAndVolume(data)

		vf1,vf2 = volFrac(box)
		print file,atoms,vf1,vf2

main()
