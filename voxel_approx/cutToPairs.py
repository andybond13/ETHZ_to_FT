
import os


def main(infile):
    print i
    out = i[:-13]+"pairs.txt"
    print out
    f = open(i,'rU')
    fo = open(out,'w+')
    for line in f:
        ls = line.split()
        if (len(ls) > 4 and ls[0] != "done"):
            line = line.translate(None, ':')
            fo.write(line)

for i in os.listdir(os.getcwd()):
    if i.endswith("pairsOnly.txt"): 
        main(i)
        continue
    else:
        continue
