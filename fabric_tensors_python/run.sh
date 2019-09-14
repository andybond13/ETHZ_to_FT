#!/bin/bash
#time /sw/bin/python2.7 plot_fabric_tensor.py --3d --plot --raw --png=contact_test_3d.png contact_test_3d.txt 
time /sw/bin/python2.7 plot_fabric_tensor.py --3d --plot --raw --png=contact_test_3d.png contact_test_3d_2.txt 
time /sw/bin/python2.7 plot_fabric_tensor.py --rz --plot --raw --png=contact_test_2d_rz.png contact_test_2d_rz.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --raw contact_test_2d.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --writeF4=contact_test_2d.ft --png=contact_test_2d.png --raw contact_test_2d.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --writeF4=contact_test_2d_weighted.ft --png=contact_test_2d_weighted.png --raw contact_test_2d_weighted.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --3d --writeF4=contact_test_3d_weighted.ft --png=contact_test_3d_weighted.png contact_test_3d_weighted.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --3d --writeF2=90wt_0bar.ft --writeF4=90wt_0bar.ft --png=90wt_0bar.png 90wt_0bar_contact_contact.txt


#check 3d-polar vs 2d-rz plots (they are different.?..

#check N & F tensors (maybe need to make more unfirm data)
#fractional anistropy also doesn't match
#check stat signicance 

# I might need some math to do this... not quite as trivial as I thought
#are 6th order stats available?
#make separate repo
