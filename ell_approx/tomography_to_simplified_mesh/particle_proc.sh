#!/bin/tcsh -x

set ary=`perl -e '{@a=(2001..2010); print "@a\n";}'`
set fix=( $ary )
# set fix=(1 2 3 4 5 6 7 8 9 10)

foreach MY_IDX ( $fix )
    set i=`printf "Island_%06d" ${MY_IDX}`
    set MY_ARG=`egrep "^${MY_IDX} " image.idx`
    scanStackRangeGrain1.pl ${MY_ARG} --zfile -o ${i}.pts
    rm -f pc.off axis.off axisface.off inpball inpole outpole pc.off poleinfo
    minpts.pl ${i}.pts ${i}.mpts
    ptssub.pl ${i}.pts ${i}.mpts ${i}.ptm
    mkdir -p _tmp/${MY_IDX}
    cd _tmp/${MY_IDX}
       powercrust -R 1.6 -i ../../${i}.ptm
       simplify -i poleinfo -o simp_poles -n 3.0 -r 3.0
       powercrust -p -i simp_poles
       orient -i pc.off -o ../../${i}.off
       cd ../../
    off2obj ${i}.off ${i}.obj -DGROUP_LABEL=${i} -DSHIFTF=${i}.mpts
    set MY_FAC=`objnf ${i}.obj`
    set MY_NPL=`polyset ${MY_FAC}`
    qslim -t ${MY_NPL} -o ${i}.kbj ${i}.obj
    rm -f _tt
    echo "g ${MY_IDX}" > _tt
    cat ${i}.kbj >> _tt
    mv _tt ${i}.kbj
    obj2stl ${i}.kbj ${i}.stl
    obj2mesh1  ${i}.kbj ${i} -DGROUP_LABEL
end

meshcat Island_*.mesh all.mesh -DCLEAN
objcat Island_*.kbj all.obj
obj2stl all.obj all.stl
