#!/bin/tcsh

foreach  i ( 0 1 2 3 4 5 6 7 8 9 )
  meshcat Island_00${i}???.mesh i0${i}.mesh -DCLEAN
end

foreach  i ( 0 1 2 3 4 5 6 7 8 9 )
  meshcat Island_01${i}???.mesh i1${i}.mesh -DCLEAN
end

meshcat i??.mesh all.mesh -DCLEAN
