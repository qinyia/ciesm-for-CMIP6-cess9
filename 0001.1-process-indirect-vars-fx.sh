
datadir=$1
casename=$2
outdir=$3
int_year=$4
end_year=$5
int_mon=$6
end_mon=$7
var_in=$8

echo "datadir=" $datadir
echo "casename=" $casename
echo "outdir=" $outdir
echo "int_year=" $int_year
echo "end_year=" $end_year
echo "int_mon=" $int_mon
echo "end_mon=" $end_mon
echo "var_in=" $var_in

if [ ! -d "$outdir" ];then
	mkdir -p $outdir
fi

iyr0_4d=`printf %04d ${int_year}`
echo ${iyr0_4d}
imon_2d=`printf %02d ${int_mon}`
echo ${imon_2d}
file=`ls $datadir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}.nc`
echo $file

cd $outdir

if [ "$var_in" == "areacella" ]; then
	ncks -v FSNT $file ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fsnt.nc
	cdo gridarea ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fsnt.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_${var_in}.nc
	ncrename -O -v cell_area,areacella ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_${var_in}.nc
	rm -rf $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fsnt.nc
fi

if [ "$var_in" == "sftlf" ]; then
	ncks -O -v LANDFRAC $file ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_${var_in}.nc
	ncrename -O -v LANDFRAC,sftlf ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_${var_in}.nc
	ncap2 -O -s 'sftlf=sftlf*100' ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_${var_in}.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_${var_in}.nc
	ncwa -O -a time ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_${var_in}.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_${var_in}.nc
fi

echo "finish processing indirect output variables~"



