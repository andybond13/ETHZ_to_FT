#!superseceded - visit /battery/ETH_labeled_particles/tmp

include /Users/andrewstershic/Desktop/meshing/imagery_90wt_0bar/filelist.in
# meshfiles = Island_0001.mesh Island_0002.mesh Island_0003.mesh Island_0004.mesh Island_0005.mesh Island_0006.mesh Island_0007.mesh Island_0008.mesh Island_0009.mesh Island_0010.mesh
# end filelist.in

NPOLY=1000
RVAL=0.6

all : $(meshfiles)
	meshcat $(meshfiles) all.mesh -DCLEAN

%.pts : image.idx
	$(eval MY_IDX:=$(shell echo $@ | sed 's/Island_0*//' | sed 's/\.pts//'))
	$(eval MY_ARG:=$(shell egrep "^${MY_IDX} " image.idx))
	scanStackRangeGrain1.pl ${MY_ARG} --zfile -o $@

%.obj : %.pts
# powercrust uses reserved file names
# need to fix that or move into separate directories
# had to normalize box for the points
# powercrust does not do that internally
# had to move implicit rule for obj:off here to apply coordinate shift
	$(eval MY_NAM:=$(shell echo $@ | sed 's/\.obj//'))
	$(eval MY_IDX:=$(shell echo $@ | sed 's/Island_0*//' | sed 's/\.obj//'))
	minpts.pl $< ${MY_NAM}.mpts
	ptssub.pl $< ${MY_NAM}.mpts ${MY_NAM}.ptm
	mkdir -p _tmp/${MY_IDX}
	cd _tmp/${MY_IDX} ; powercrust -R ${RVAL} -i ../../${MY_NAM}.ptm ; orient -i pc.off -o ../../${MY_NAM}.off
	off2obj ${MY_NAM}.off $@ -DGROUP_LABEL=${MY_IDX} -DSHIFTF=${MY_NAM}.mpts
	rm -f ${MY_NAM}.off ${MY_NAM}.mpts ${MY_NAM}.ptm

%.obj : %.off
	$(eval MY_IDX:=$(shell echo $@ | sed 's/Island_0*//' | sed 's/\.obj//'))
	off2obj $< $@ -DGROUP_LABEL=${MY_IDX}

%.kbj : %.obj
# parameter NPOLY for qslim should be based on particle size and complexity
# maybe number of initial polygons
# there should be more commands here
	qslim -t ${NPOLY} -o $@ $<

%.mesh : %.kbj
	$(eval MY_NAM:=$(shell echo $@ | sed 's/\.mesh//'))
	obj2mesh1 $< ${MY_NAM} -DGROUP_LABEL

# comment line if do not want to save intermediate files
# by default all are saved
.PRECIOUS: %.pts
.PRECIOUS: %.obj
.PRECIOUS: %.kbj

tidy :
	rm -f *.kbj
	rm -f *.obj
	rm -f *.off
	rm -f *.pts
	rm -rf _tmp

clean : tidy
	rm -f *.mesh
