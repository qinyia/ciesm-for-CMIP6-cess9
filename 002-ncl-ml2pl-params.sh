
datadir=$1
casename=$2
outdir=$3
int_year=$4
end_year=$5
int_mon=$6
end_mon=$7
vars_plev_in=$8
vars_alev_in=$9

echo "datadir=" $datadir
echo "casename=" $casename
echo "outdir=" $outdir
echo "int_year=" $int_year
echo "end_year=" $end_year
echo "int_mon=" $int_mon
echo "end_mon=" $end_mon
echo "vars_plev_in=" $vars_plev_in
echo "vars_alev_in=" $vars_alev_in


if [ ! -d "$outdir" ];then
	mkdir -p $outdir
fi

for iyr0 in `seq $int_year $end_year`
do
        iyr0_4d=`printf %04d $iyr0`
        echo ${iyr0_4d}
		
		for imon in `seq $int_mon $end_mon`
		do
			imon_2d=`printf %02d $imon`
			echo $imon_2d
			file=`ls $datadir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}.nc`
			echo $file
			
			# extract desired variables
			ncks -O -v hyai,hyam,hybi,hybm,PS,PHIS,P0,${vars_plev_in} $datadir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}.nc $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp.nc

			# interpolate from model level to pressure level
			cd $outdir
			echo $vars_plev_in
			export fn=${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp.nc
#			export fo=${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc
#			rm -f ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc
			export fo=${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp1.nc
			rm -f ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp1.nc
			export vars=${vars_plev_in}
			echo $vars
			cp /GPFS/cess9/qinyi/CMOR3/001-ncl-vinth2p.ncl /GPFS/cess9/qinyi/CMOR3/001-ncl-vinth2p-${casename}.${iyr0_4d}-${imon_2d}.ncl
			ncl /GPFS/cess9/qinyi/CMOR3/001-ncl-vinth2p-${casename}.${iyr0_4d}-${imon_2d}.ncl

			# change lev name from "lev" to "plev" avoiding its confusion with variable on model grid
#			ncrename -v lev,plev ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp1.nc
#			ncrename -d lev,plev ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp1.nc

			# get total precipitation rate 
			ncks -O -v PRECC,PRECL $datadir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_preccl.nc
			ncap2 -O -s 'PRECT=PRECC+PRECL' ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_preccl.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_prect.nc
			`cp $datadir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_addprect.nc`
			ncks -A -v PRECT ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_prect.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_addprect.nc
			ncatted -a long_name,PRECT,o,c,"total precipitation rate" ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_addprect.nc

			# extract vars_alev_in
#			ncks -O -v hyai,hyam,hybi,hybm,PS,PHIS,${vars_alev_in} $datadir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_plev19.nc
			ncks -O -v hyai,hyam,hybi,hybm,PS,PHIS,${vars_alev_in} ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_addprect.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_plev19.nc

			# append interpolated plev19 variables to other variables
			ncks -A ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp1.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_plev19.nc 
			
			# force the time calendar to noleap -- don't need it anymore
#			ncatted  -a calendar,time,o,c,"noleap" ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_plev19.nc
			# change longname of latitude/longitude to "latitude"/"longitude", not Latitude..
			ncatted  -a long_name,lat,o,c,"latitude" ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_plev19.nc
			ncatted  -a long_name,lon,o,c,"longitude" ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_plev19.nc
			
			
#			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc
			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp.nc
			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp1.nc
			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_preccl.nc
			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_prect.nc
			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_addprect.nc
			rm -f /GPFS/cess9/qinyi/CMOR3/001-ncl-vinth2p-${casename}.${iyr0_4d}-${imon_2d}.ncl

			echo "finish interpolation~"
		done
done



