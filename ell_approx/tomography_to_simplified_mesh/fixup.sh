#!/bin/tcsh

# particles to fix, the ones that have shooting nodes
set fix=( 13512 13607 )

foreach h ( $fix )
   set i=`printf "Island_%06d" $h`
   rm -f pc.off axis.off axisface.off inpball inpole outpole pc.off poleinfo
   minpts.pl ${i}.pts ${i}.mpts
   ptssub.pl ${i}.pts ${i}.mpts ${i}.ptm
   powercrust -R 0.6 -i ${i}.ptm
#  two new steps
   simplify -i poleinfo -o simp_poles -n 3.0 -r 3.0
   powercrust -p -i simp_poles
#
   orient -i pc.off -o ${i}.off
   off2obj ${i}.off ${i}.obj -DGROUP_LABEL=${i} -DSHIFTF=${i}.mpts
   qslim -t 1000 -o ${i}.kbj ${i}.obj
   obj2mesh1  ${i}.kbj ${i} -DGROUP_LABEL
end
