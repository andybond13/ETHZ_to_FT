#!/bin/bash
time /sw/bin/python2.7 plot_fabric_tensor.py --3d --plot --raw contact_test_3d.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --raw contact_test_2d.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --write=contact_test_2d.ft --png=contact_test_2d.png --raw contact_test_2d.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --write=contact_test_2d_weighted.ft --png=contact_test_2d_weighted.png --raw contact_test_2d_weighted.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --3d --write=contact_test_3d.ft --png=contact_test_3d.png contact_test_3d.txt 
#time /sw/bin/python2.7 plot_fabric_tensor.py --plot --3d --write=90wt_0bar.ft --png=90wt_0bar.png 90wt_0bar_contact_contact.txt


#confirm stats. find an example; maybe compare against mmtensor (also... I ommitted the symmetrization of indices in calculation of F4+, D4+, and stat4+)
#examine mmtensor code, compare code
#make an example problem, compare to MMTensor
#confirm/debug writing to files / saving files
