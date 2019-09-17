

job="003.2-change-FillValue_0914"

curdir=`pwd`

date=`date`
echo $date
echo ${job}.log

bsub -b -m 1 -p -q q_x86_cn_cess_1 -J CMIP6_output -n 1 -o $curdir/${job}.log sh $curdir/$job.sh

