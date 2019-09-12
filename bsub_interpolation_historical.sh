

#years=("300-350yr" "350-400yr" "400-450yr" "450-500yr")
#years=("500-550yr" "550-600yr" "600-650yr" "650-700yr" "700-750yr" "750-800yr")
years=("1" "2")

nyear=${#years[@]}
echo $nyear

for iyear in `seq 0 $[$nyear-1]`
do
#	job="interpolation_"${years[iyear]}
	job="003-interpolation_ncl_historical_"${years[iyear]}

	curdir=`pwd`

	date=`date`
	echo $date
	echo ${job}_${iyear}.log

	bsub -b -m 1 -p -q q_x86_cn_cess_1 -J vert_regrid -n 1 -o $curdir/${job}_${iyear}.log python $curdir/$job.py

done

