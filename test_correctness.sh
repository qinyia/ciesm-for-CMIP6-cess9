
# Description:
# this script is used to check the correctness after CMOR output
# Author: Yi Qin
# Created: Aug 8, 2019

dates=20190827
yearS=`printf %04d 1`
yearE=`printf %04d 1`
monthS=`printf %02d 1`
monthE=`printf %02d 1`

yearSo=`printf %04d 500`
monthSo=`printf %02d 1`

casename=PIC_g16_acc_nochem_1

var_3d=cl
var_2d=tas

exp=piControl

dir3=/GPFS/cess9/qinyi/CMOR3/CMIP6/CMIP6/CMIP/THU/CIESM/piControl/r1i1p1f1/Amon/${var_3d}/gr/v${dates}/
f3=${var_3d}_Amon_CIESM_${exp}_r1i1p1f1_gr_${yearS}${monthS}-${yearE}${monthE}.nc

dir2=/GPFS/cess1/se2fv-regrid/rgr_out/${casename}_192x288/
f2=${casename}.cam.h0.${yearSo}-${monthSo}.nc

dir1=/GPFS/cess9/qinyi/CMOR3/CMIP6/CMIP6/CMIP/THU/CIESM/piControl/r1i1p1f1/Amon/${var_2d}/gr/v${dates}/
f1=${var_2d}_Amon_CIESM_${exp}_r1i1p1f1_gr_${yearS}${monthS}-${yearE}${monthE}.nc

test_2d=True
test_3d=True

if [ "$test_2d" == "True" ]; then
	# test 2D variables
	ncks -O -v tas -d time,0 $dir1/$f1 out2.nc
	
	ncks -O -v TREFHT $dir2/$f2 out1.nc
	ncrename -O -v TREFHT,tas out1.nc
	
	ncdiff -O -v tas out2.nc out1.nc out3_2d.nc
	
	rm -f out1.nc
	rm -f out2.nc
fi

if [ "$test_3d" == "True" ]; then
	# test 3D variables on model vertical coordinate
	# extract cloud from CMOR output
	ncks -O -v cl -d time,0 $dir3/$f3 out2.nc
	# delete time dimension
	ncwa -O -a time out2.nc out2.nc
	# change name from cl to CLOUD
	ncrename -v cl,CLOUD out2.nc
	# delete time variable
	ncks -O -x -v time out2.nc out22.nc
	# invert the level: Bottom-top --> Top-bottom
	cdo invertlev out22.nc out23.nc
	
	# extract cloud
	ncks -O -v CLOUD $dir2/$f2 out1.nc
	# delete time dimension
	ncwa -O -a time out1.nc out1.nc
	# delete time and time_bnds
	ncks -O -x -v time,time_bnds out1.nc out11.nc
	
	# difference 
	ncdiff -O -v CLOUD out23.nc out11.nc out3_3d.nc
	
	rm -f out1.nc out11.nc out2.nc out22.nc out23.nc 
fi





