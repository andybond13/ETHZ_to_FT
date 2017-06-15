#!/usr/bin/python

# modify image stack by a min and max pixel value threshold

import Image
import sys
import numpy

def unique(a):
    return list(set(a))

def main(infile,mxint,mnint,outfile):
    img = Image.open(infile,'r')
    #pix = img.load()

    print "Mode = ", img.mode
    assert(len(img.getbands()) == 1)    

    xsize = img.size[0]
    ysize = img.size[1]
    imarray = numpy.array(img)

    rawData = []

    for i in range(ysize):
        colors = imarray[i,:]
        #colors = unique(colors)
        for color in colors:
            #print color
            #modify color: allow if between values, throw out otherwise
            if (color < numpy.uint8(mnint) or color > numpy.uint8(mxint)):
                color = numpy.uint8(0)
            rawData.append(color)

    #print "Raw data = ", rawData
    a = numpy.array(rawData)
    a = numpy.reshape(a,(-1,xsize))
    fh = Image.fromarray(a)
    fh.save(outfile)
    fh.show()
    

if (len(sys.argv) != 5):
	print '***wrong number of input arguments'
	print str(len(sys.argv)-1) + '!= 4. Need <input.tiff> <minint> <maxint> <output.tiff>'
else:	
    infile = sys.argv[1]
    mnint = int(sys.argv[2])
    mxint = int(sys.argv[3])
    outfile= sys.argv[4]
    main(infile,mxint,mnint,outfile)
