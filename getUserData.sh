dateInput=`date -d "1 days ago" +%m%d`
output=/user/tvapk/cuiliqing/out
inputPath=/data/tvapk/show
vvpath=/user/tvapk/peichao/TV/movieper/20160420/vvlog
jar=Features.jar
jarPath=home/tvapk/run_sh/cuiliqing
hdfs=/user/tvapk/cuiliqing
hadoop=/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop
dataSavePath=/data/tvapk/cuiliqing/cuiliqing

cd /home/tvapk/run_sh/cuiliqing
input=$dateInput
dataArv="${input}.txt"

$hadoop fs -rm -r $hdfs/$dataArv
$hadoop fs -put $inputPath/$dataArv $hdfs
$hadoop fs -rm -r $output
$hadoop jar Features.jar PersonalRecommend.GetDaliyShowGuid  $hdfs/$dataArv $output
$hadoop fs -rm -r $hdfs/$dataArv
rm ${dataSavePath}/part-r-00000
$hadoop fs -get $output/part-r-00000   $dataSavePath
$hadoop fs -rm -r $output
$hadoop jar $jar PersonalRecommend.GetDayVvGuid $vvpath/"2017"$input/*  $output
vvguid=$input"vvguid.txt"
$hadoop fs -rm -r $hdfs/$vvguid
$hadoop fs -cp $output/part-r-00000 $hdfs/$vvguid
rm $dataSavePath/$vvguid
$hadoop fs -get $hdfs/$vvguid $dataSavePath
$hadoop fs -rm -r $hdfs/$vvguid
$hadoop fs -rm -r $output

cat ${dataSavePath}/part-r-00000 ${dataSavePath}/$vvguid | sort| uniq > $dataSavePath/$input"guid.txt"
rm $dataSavePath/$vvguid
rm ${dataSavePath}/part-r-00000

