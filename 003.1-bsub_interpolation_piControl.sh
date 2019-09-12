

years=("300-350" "350-400" "400-450" "450-500" "500-550" "550-600" "600-650" "650-700" "700-750" "750-800")

nyear=${#years[@]}
echo $nyear

for iyear in `seq 0 $[$nyear-1]`
do
#	job="interpolation_"${years[iyear]}
	job="003-interpolation_ncl_piControl_"${years[iyear]}"_yr"
	echo $job

	curdir=`pwd`

	date=`date`
	echo $date

	echo ${job}_${years[iyear]}.log

	bsub -b -m 1 -p -q q_x86_cn_cess_1 -J vert_regrid_piControl -n 1 -o $curdir/${job}_${iyear}.log python $curdir/$job.py

done

