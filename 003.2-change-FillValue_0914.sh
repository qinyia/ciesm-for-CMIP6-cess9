
# Description: change FillValue from 9.9e+36 to 1e+20
# Author: Yi Qin
# Create: 2019-09-10 22:11:43

#casename=(PIC_g16_acc_nochem_1 B20TRC5_g16_acc_nochem_2 B20TRC5_g16_acc_nochem_3)
casename=(B20TRC5_g16_acc_nochem_3)

ncase=${#casename[@]}
echo $ncase

for icase in `seq 0 $[$ncase-1]`

do 
	datadir=/GPFS/cess9/qinyi/CMOR3/mid-data/$casename/
	outdir=/GPFS/cess9/qinyi/CMOR3/mid-data/$casename/FillValue/

	if [ ! -d $outdir ];then
		mkdir -p $outdir
	fi

	rm -rf $outdir/*

	echo $datadir
	cd $datadir

	for file in `ls ${casename}*`
	do
		file_name=`echo $file`	
		echo $file_name
#		cdo -setmissval,1e+20 $file_name $outdir/${file_name}_FillValue.nc
		ncatted -a _FillValue,,o,f,1e20 $file_name $outdir/${file_name}_FillValue.nc
	done
done
