#!/bin/bash



#making unclustered voxel-based contact lists
 ./scanStackRangeContact.pl ../ETHZ_imagery/NMC_90wt_0bar/NMC_90wt_0bar_*.tif > NMC_90wt_0bar_rawData.txt
 ./scanStackRangeContact.pl ../ETHZ_imagery/NMC_90wt_300bar/NMC_90wt_300bar_*.tif > NMC_90wt_300bar_rawData.txt
 ./scanStackRangeContact.pl ../ETHZ_imagery/NMC_90wt_600bar/NMC_90wt_600bar_*.tif > NMC_90wt_600bar_rawData.txt
 ./scanStackRangeContact.pl ../ETHZ_imagery/NMC_90wt_2000bar/NMC_90wt_2000bar_*.tif > NMC_90wt_2000bar_rawData.txt
#etc


#make local contact normal list
python cutToPairs.py NMC_90wt_0bar_rawData.txt
python cutToPairs.py NMC_90wt_300bar_rawData.txt
python cutToPairs.py NMC_90wt_600bar_rawData.txt
python cutToPairs.py NMC_90wt_2000bar_rawData.txt
#etc



#for centroid vector, need to use matlab files
