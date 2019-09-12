
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

			# add the standard_name for PS to help cdo identify the PS variable
			# notion: surface geopotential is also needed for vertical interpolation
			ncatted -O -a standard_name,PS,c,c,"surface_air_pressure" $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp.nc $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc
			ncatted -O -a standard_name,PHIS,c,c,"surface_geopotential" $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc
			echo "finish ncatted~"

			# change hyai or hyam from the unit bar to Pa
			# ECHAM: P = A + B*PS; CAM: P=A*P0 + B*PS
			ncap2 -O -s "hyai=hyai*100000;hyam=hyam*100000;" $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc
			# interpolate from model level to pressure level
			cd $outdir
			echo $vars_plev_in
#			ncatted -a bounds,lev,c,c,"ilev" $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc
			# add bounds to lev
			ncap2 -O -s 'lev@bounds="lev_bnds";defdim("bnds",2);lev_bnds[$lev,$bnds]=0.0;lev_dff=0.5*(lev(1)-lev(0));lev_bnds(:,0)=lev-lev_dff;lev_bnds(:,1)=lev+lev_dff;' $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc
			ncatted -O -a formula_terms,lev_bnds,c,c,"a: hyam_bnds b: hybm_bnds p0: P0 ps: PS" $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc
			cdo -setmissval,1e+20 -ml2pl,100000,92500,85000,70000,60000,50000,40000,30000,25000,20000,15000,10000,7000,5000,3000,2000,1000,500,100 -selvar,PS,PHIS,${vars_plev_in} ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp1.nc

			#cdo -setmissval,1e+20 -ml2pl,100000,92500,85000,70000,60000,50000,40000,30000,25000,20000,15000,10000,7000,5000,3000,2000,1000,500,100 -selvar,PS,PHIS,hyam,hyai,hybm,hybi,P0,${vars_plev_in} ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc ${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp1.nc
exit

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
			
			
			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_myfile.nc
			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp.nc
			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_tmp1.nc
			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_preccl.nc
			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_prect.nc
			rm -f $outdir/${casename}.cam.h0.${iyr0_4d}-${imon_2d}_addprect.nc

			echo "finish interpolation~"
		done
done



