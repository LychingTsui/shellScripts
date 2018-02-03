#!/usr/bin/sh
for i in `seq 5 10`; do
        #echo "$i  "
        day=`date -d "$i days ago " "+%Y%m%d"`
        Arr[$i-5]=$day
        echo $day
done
arr=($(seq 5 10))
echo ${Arr[@]}

