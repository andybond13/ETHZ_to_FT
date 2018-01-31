#!/bin/bash
#time /sw/bin/python2.7 plot_fabric_tensor.py --3d --plot --raw contact_test_3d.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --raw contact_test_2d.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --writeF4=contact_test_2d.ft --png=contact_test_2d.png --raw contact_test_2d.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --writeF4=contact_test_2d_weighted.ft --png=contact_test_2d_weighted.png --raw contact_test_2d_weighted.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --3d --writeF4=contact_test_3d_weighted.ft --png=contact_test_3d_weighted.png contact_test_3d_weighted.txt 
time /sw/bin/python2.7 plot_fabric_tensor.py --plot --3d --writeF2=90wt_0bar.ft --writeF4=90wt_0bar.ft --png=90wt_0bar.png 90wt_0bar_contact_contact.txt


#are 6th order stats available?
#confirm/debug writing to files / saving files
#I don't trust polar plot. for data=I(3), it's not the same magnitude in Z & r. Need some correction factor for r I think.
