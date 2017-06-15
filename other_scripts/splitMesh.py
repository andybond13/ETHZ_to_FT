#!/sw/bin/python2.7
#000006, hole: 1664 1656, surface: 25
import sys

def printable(vector):
	out = ""
	for i in range(0,len(vector)):
		item = vector[i]
		if (i > 0):
			out += " "
		out += str(item)
	return out

def findHoles(vertices,triangles,index):

	#if vertex is not in hole
	if (vertices[index-1][3] == 1):
		#put into ref #2
		vertices[index-1][3] = 2
		#find triangle(s) it belongs to
		tri = []
		for i in range(0,len(triangles)):
			if index in triangles[i][0:3]:
				tri.append(i)
#		print "index ",index,"  triangles ",tri
		for thisTri in tri: 
			trivert = triangles[thisTri][0:3]
			triangles[thisTri][3] = 2
#			print "triangle",thisTri,"index",trivert
			for vert in trivert:
#				print "vert",vert
				findHoles(vertices,triangles,vert)
		

	return vertices,triangles

def readMesh(meshinput):
	hole = 0
	vertices = []
	triangles = []
	numVert = -1
	numTri = -1
	
	with open(meshinput,'r') as f:
		vert = -2
		tri = -2
		for line in f:
			line = line.strip()
#			print line
			if (line[0:8] == "Vertices"):
				vert += 1
			elif (line[0:9] == "Triangles"):
				tri += 1
			elif (vert > -2 and tri == -2):
				if (vert == -1):
#					print "vertex count"
					numVert = int(line)
					vert += 1
				else:
					splitLine = line.split()
					if (len(splitLine) == 4):
						vert += 1
						splitLine[0] = float(splitLine[0])
						splitLine[1] = float(splitLine[1])
						splitLine[2] = float(splitLine[2])
						splitLine[3] = int(splitLine[3])
						vertices.append(splitLine)
			elif (vert > -2 and tri > -2):
				if (tri == -1):
#					print "triangle count"
					numTri = int(line)
					tri += 1
				else:
					splitLine = line.split()
					if (len(splitLine) == 4):
						tri += 1
						splitLine[0] = int(splitLine[0])
						splitLine[1] = int(splitLine[1])
						splitLine[2] = int(splitLine[2])
						splitLine[3] = int(splitLine[3])
						triangles.append(splitLine)

	assert(numTri == tri)
	assert(numVert == vert)

	return vertices,triangles

def writeMesh(name,vertices,triangles):
	outname = name+".a.mesh"
	with open(outname,'w') as f:
		f.write("#made by splitMesh.py from "+name+".mesh\n")
		f.write("# Groups\n")
		f.write("#   group 1 label 1 - hole\n")
		f.write("#   group 2 label 2 - exterior\n\n")
		f.write("MeshVersionFormatted 1\n\n")
		f.write("Dimension\n")
		f.write("3\n")
		f.write("Vertices\n")
		f.write(str(len(vertices))+"\n")
		
		for vertex in vertices: 
			f.write(printable(vertex)+"\n")
		
		f.write("\n")
		f.write("Triangles\n")
		f.write(str(len(triangles))+"\n")
		
		for triangle in triangles:
			f.write(printable(triangle)+"\n")	

		f.write("\n")
		f.write("End\n")
	
	return 0

def main(input):

	print input
	fullInput = input
	input = input.split('.')
	print input

	name = input[0]
	assert(input[1] == 'mesh')

	vertices,triangles = readMesh(fullInput)
	vertices,triangles = findHoles(vertices,triangles,1)
	writeMesh(name,vertices,triangles)

input = sys.argv[1]
main(input)

