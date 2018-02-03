dateInput=`date -d "1 days ago" +%Y%m%d`
year=${dateInput:0:4}

#read -p "please input 2 args: args1: date starting format<0801>, args2:day length,format<an integer number>   "
#dateStart  daylen
output=/user/tvapk/cuiliqing/outguid
inputPath=/data/tvapk/show/
vvpath=/user/tvapk/peichao/TV/movieper/20160420/vvlog/
jar=Features.jar   #######
jarPath=home/tvapk/run_sh/cuiliqing/
hdfs=/user/tvapk/cuiliqing/
hadoop=/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop
dataSavePath=/data/tvapk/cuiliqing/cuiliqing/

input=${dateInput:4}
dataArv="${input}.txt"
#inputPath="/data/tvapk/show/"
#vvpath="/user/tvapk/peichao/TV/movieper/20160420/vvlog/"
#jar="Features.jar"   #######
#jarPath="home/tvapk/run_sh/cuiliqing/"
#hdfs="/user/tvapk/cuiliqing/"
#hadoop="/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop"
#dataSavePath="/data/tvapk/cuiliqing/cuiliqing/"

$hadoop fs -rm -r $hdfs$dataArv
$hadoop fs -put $inputPath$dataArv $hdfs
$hadoop fs -rm -r $output
$hadoop jar $jar PersonalRecommend.GetDaliyShowGuid  $hdfs$dataArv $output
$hadoop fs -rm -r $hdfs$dataArv
showguid=$input"showguid"
#rm ${dataSavePath}part-r-00000
$hadoop fs -rm -r  $hdfs$showguid
$hadoop fs -cp $output/part-r-00000   $hdfs$showguid
$hadoop fs -rm -r $output
rm $dataSavePath$showguid
$hadoop fs -get $hdfs$showguid  $dataSavePath
$hadoop fs -rm -r $hdfs$showguid
$hadoop jar $jar PersonalRecommend.GetDayVvGuid $vvpath$year$input/*  $output
vvguid=$input"vvguid"
$hadoop fs -rm -r $hdfs$vvguid
$hadoop fs -cp $output/part-r-00000 $hdfs$vvguid
rm $dataSavePath$vvguid
$hadoop fs -get $hdfs$vvguid $dataSavePath
$hadoop fs -rm -r $hdfs$vvguid
$hadoop fs -rm -r $output

cat ${dataSavePath}$showguid ${dataSavePath}$vvguid | sort| uniq > $dataSavePath$input"guid.txt"
rm $dataSavePath$vvguid
rm ${dataSavePath}$showguid

