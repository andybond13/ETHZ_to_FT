
import os


def main(infile):
    print "in:",i
    out_data = i[:-11]+"pairs.txt"
    out_pairs = i[:-11]+"vec.out"
    print "out:",out_data, out_pairs
    f = open(i,'rU')
    fo = open(out_data,'w+')
    fp = open(out_pairs,'w+')
    for line in f:
        ls = line.split()
        if (len(ls) > 4 and ls[0] != "done"):
            line = line.translate(None, ':')
            fo.write(line)
        if (len(ls) == 4 and ls[0] != "done"):
            fp.write(line)

for i in os.listdir(os.getcwd()):
    if i.endswith("rawData.txt"): 
        main(i)
        continue
    else:
        continue
