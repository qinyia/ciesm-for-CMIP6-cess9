
# Description: according to the file name (start and end year) to change the int_year and end_year in each file for piControl.
# Author: Yi Qin
# Created: 2019-09-10 17:49:30


## find all piControl files
for file in `ls ./*interpolation_ncl_piControl*`
do
	echo $file
	file_name=`echo $file`
	echo $file_name
	# get the start and end year for each file
	yearS=`echo $file | cut -f2 -d "-" | awk -F "_" '{print $4}'` 
	yearE=`echo $file | cut -f3 -d "-" | awk -F "_" '{print $1}'`
	echo $yearS
	echo $yearE
	# print the content at line 44 and 45
	sed -n '44,45p' ${file_name}
	# set the replacing content
	int_year='int_year=['$[yearS+1]']'
	end_year='end_year=['${yearE}']'
	echo $int_year
	echo $end_year
	# replace the whole line (44 and 45) with int_year and end_year
	# \\t is the TAB.
	# pay attention to the syntax to refer variable in sed command.
	sed -i '44c \\t'"${int_year}"'' ${file_name}
	sed -i '45c \\t'"${end_year}"'' ${file_name}
done

