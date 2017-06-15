#!/bin/tcsh

foreach i ( *.tif )
  echo $i
  set l=`echo $i | sed 's/\.tif/\.pnm/'`
  if (-e tmp/$l) rm tmp/$l
  if (-e tmp/$i) rm tmp/$i
  /sw/bin/tifftopnm -byrow $i > tmp/$l
  /sw/bin/pnmtotiff tmp/$l > tmp/$i
  if (-e tmp/$l) rm tmp/$l
end

