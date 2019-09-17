
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

			cd $outdir

			if [ "$var_in" == "rlus" ]; then
				# get surface upwelling longwave flux
				ncks -O -v FLDS,FLNS $datadir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fls.nc
				ncap2 -O -s 'rlus=FLDS-FLNS' ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fls.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rlus.nc
				ncatted -a long_name,rlus,o,c,'surface upwelling longwave flux in air' ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rlus.nc
				ncatted -a _FillValue,,o,f,1e20  ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rlus.nc
				rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fls.nc
			fi
			if [ "$var_in" == "rsus" ]; then
				# get surface upwelling shortwave flux
				ncks -O -v FSDS,FSNS $datadir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fss.nc
				ncap2 -O -s 'rsus=FSDS-FSNS' ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fss.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rsus.nc
				ncatted -a long_name,rsus,o,c,'surface upwelling shortwave flux in air' ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rsus.nc
				ncatted -a _FillValue,,o,f,1e20  ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rsus.nc
				rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fss.nc
			fi

			if [ "$var_in" == "rsuscs" ]; then
				# get surface upwelling shortwave in clearsky
				ncks -O -v FSDSC,FSNSC $datadir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fssc.nc
				ncap2 -O -s 'rsuscs=FSDSC-FSNSC' ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fssc.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rsuscs.nc
				ncatted -a long_name,rsuscs,o,c,'surface upwelling shortwave flux in air assuming clear-sky' ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rsuscs.nc
				ncatted -a _FillValue,,o,f,1e20  ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rsuscs.nc
				rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fssc.nc
			fi
			if [ "$var_in" == "rtmt" ]; then
				# get net downward radiative flux at top of atmosphere model
				ncks -O -v FSNT,FLNT $datadir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fnt.nc
				ncap2 -O -s 'rtmt=FSNT-FLNT' ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fnt.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rtmt.nc
				ncatted -a long_name,rtmt,o,c,'net downward radiative flux at top of atmosphere model' ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rtmt.nc
				ncatted -a _FillValue,,o,f,1e20  ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_rtmt.nc
				rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_fnt.nc
			fi
			

			echo "finish processing indirect output variables~"
		done
done



