
# Description: 
# 1. use the basename file to form all needed files for multi-processing
# 2. according to the file name (start and end year) to change the int_year and end_year in each file for piControl.

# Author: Yi Qin
# Created: 2019-09-10 17:49:30


getfiles=False
changetime=True

basename=004-qy_test_doc_read_rawdata_piControl

## form all files for multi-processing
if [ "$getfiles" == "True" ]; then
	years=("300-350" "350-400" "400-450" "450-500" "500-550" "550-600" "600-650" "650-700" "700-750" "750-800")
	nyear=${#years[@]}
	echo $nyear

	for iyear in `seq 0 $[$nyear-1]`
	do 
		filename=${basename}_${years[iyear]}"_yr"
		echo $filename

		cp ${basename}.py ${filename}.py
	done
	exit
fi 

if [ "$changetime" == "True" ];then

## find all piControl files
for file in `ls ./${basename}_*`
do
	echo $file
	file_name=`echo $file`
	echo $file_name
	# get the start and end year for each file
	yearS=`echo $file | cut -f2 -d "-" | awk -F "_" '{print $7}'` 
	yearE=`echo $file | cut -f3 -d "-" | awk -F "_" '{print $1}'`
	echo $yearS
	echo $yearE
	# print the content at line 28 and 29
	sed -n '28,29p' ${file_name}
	# set the replacing content
	int_year='int_year=['$[yearS+1]']'
	end_year='end_year=['${yearE}']'
	echo $int_year
	echo $end_year
	# replace the whole line (28 and 29) with int_year and end_year
	# \\t is the TAB.
	# pay attention to the syntax to refer variable in sed command.
	sed -i '28c '"${int_year}"'' ${file_name}
	sed -i '29c '"${end_year}"'' ${file_name}
done

fi
