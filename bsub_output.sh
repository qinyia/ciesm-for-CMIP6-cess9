

years=("300-350yr" "350-400yr" "400-450yr" "450-500yr" "500-550yr" "550-600yr" "600-650yr" "650-700yr" "700-750yr" "750-800yr")

nyear=${#years[@]}
echo $nyear

for iyear in `seq 0 $[$nyear-1]`
do
	job="0827_qy_test_doc_read_rawdata_"${years[iyear]}

	curdir=`pwd`

	date=`date`
	echo $date
	echo ${job}_${iyear}.log

	bsub -b -m 1 -p -q q_x86_cn_cess_1 -J CMIP6_output -n 1 -o $curdir/${job}_${iyear}.log python $curdir/$job.py

done

#bsub -b -m 1 -p -q q_x86_cn_cess_1 -J vert_regrid -n 1 -o $curdir/$job1.log python $curdir/$job1.py
#bsub -b -m 1 -p -q q_x86_cn_cess_1 -J vert_regrid -n 1 -o $curdir/$job2.log python $curdir/$job2.py
#bsub -b -m 1 -p -q q_x86_cn_cess_1 -J vert_regrid -n 1 -o $curdir/$job3.log python $curdir/$job3.py
#bsub -b -m 1 -p -q q_x86_cn_cess_1 -J vert_regrid -n 1 -o $curdir/$job4.log python $curdir/$job4.py
#bsub -b -m 1 -p -q q_x86_cn_cess_1 -J vert_regrid -n 1 -o $curdir/$job5.log python $curdir/$job5.py
#bsub -b -m 1 -p -q q_x86_cn_cess_1 -J vert_regrid -n 1 -o $curdir/$job6.log python $curdir/$job6.py

