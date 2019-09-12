
exp_id=piControl
years=("300-350" "350-400" "400-450" "450-500" "500-550" "550-600" "600-650" "650-700" "700-750" "750-800")

nyear=${#years[@]}
echo $nyear

for iyear in `seq 0 $[$nyear-1]`
do
#	job="003-interpolation_ncl_piControl_"${years[iyear]}"_yr"
	job="004-qy_test_doc_read_rawdata_${exp_id}_"${years[iyear]}"_yr"
	echo $job

	curdir=`pwd`

	date=`date`
	echo $date

	logfile=${job}_${iyear}.log
	echo $logfile

	if [ ! -f "$logfile" ]; then
		rm -f $logfile
	fi

	bsub -b -m 1 -p -q q_x86_cn_cess_1 -J CMOR_out_${exp_id} -n 1 -o $curdir/${job}_${iyear}.log python $curdir/$job.py

done

