
datadir=/home/lyl/WORK4/cesm1_2_1/archive/FAMIPC5_f09f09_MG10_amip/atm/hist/
echo $datadir
cd $datadir
outdir=/home/share/lyl/work1/cesm1_2_1/CMOR3/cmor/my_tests/mid-data/
echo $outdir

if [ ! -f "$outdir/out3.nc" ]; then
	# add the standard_name for PS to help cdo identify the PS variable
	# notion: surface geopotential is also needed for vertical interpolation
	ncatted -O -a standard_name,PS,c,c,"surface_air_pressure" $datadir/FAMIPC5_f09f09_MG10_amip.cam.h0.1980-12.nc $outdir/myfile.nc
	ncatted -O -a standard_name,PHIS,c,c,"surface_geopotential" $outdir/myfile.nc
	echo "finish ncatted~"
	# interpolate from model level to pressure level
	cd $outdir
	cdo -setmissval,1e+20 -ml2pl,100000,92500,85000,70000,60000,50000,40000,30000,25000,20000,15000,10000,7000,5000,3000,2000,1000,500,100 -selvar,T,PS,PHIS,TREFHT myfile.nc out3.nc
	
	echo "finish interpolation~"
fi

