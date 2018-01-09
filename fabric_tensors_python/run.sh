#!/bin/bash
time /sw/bin/python2.7 fabric_tensor.py 90wt_0bar_contact_contact.txt
time /sw/bin/python2.7 fabric_tensor.py --3d 90wt_0bar_contact_contact.txt


#look into anisotropy measure ../fabric_tensors/tensor/fractional_anisotropy.m
#need to add weighting
#need to add plotting
