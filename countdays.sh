
function countDayLen(){
 
    #day=`date -d "1 days ago " "+%Y%m%d"`;
    year="2017"
    #year=`expr substr ${day} 1 4`;
    #month=`expr substr ${day} 5 2`;
    s_date=$year$1;
    e_date=$year$2
    #echo $e_date
    sys_s_data=`date -d "$s_date" +%s`
    #echo $sys_s_data
    sys_e_data=`date -d "$e_date" +%s`
    interval=`expr $sys_e_data - $sys_s_data`
    #echo $interval
    daycount=`expr $interval / 3600 / 24`
    return  $daycount
}
