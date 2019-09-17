
exp_id=historical
years=("1" "2")

nyear=${#years[@]}
echo $nyear

for iyear in `seq 0 $[$nyear-1]`
do
#	job="003-interpolation_ncl_piControl_"${years[iyear]}"_yr"
# 004-qy_test_doc_read_rawdata_historical_0914_1.py
	job="004-qy_test_doc_read_rawdata_${exp_id}_0914_"${years[iyear]}""
	echo $job

	curdir=`pwd`

	date=`date`
	echo $date

	echo ${job}_${years[iyear]}.log

	bsub -b -m 1 -p -q q_x86_cn_cess_1 -J CMOR_out_0914_${exp_id} -n 1 -o $curdir/${job}_${iyear}.log python $curdir/$job.py

done

