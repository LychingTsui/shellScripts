
#输入/user/tvapk/peichao/TV/movieper/20160420/vvlog
# 除hadoop 输入上路径 及 输出路径外 第三个参数 输入时间起始日期戳 例如201710即可，目前还没有实现到日的截止
# ，只实现了到月份的截止。

dateStart=$dateStart
hadoop="/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop"
input="/user/tvapk/peichao/TV/movieper/20160420/vvlog"
output="/user/tvapk/cuiliqing/outVvHistory" 
jarpth="/home/tvapk/run_sh/cuiliqing/"
jar="getvvHistory.jar"
hdfs="/user/tvapk/cuiliqing/"
dataPth="/data/tvapk/cuiliqing/cuiliqing/"
$hadoop fs -rm -r $output

$hadoop jar $jarpth$jar PersonalRecommend.GetUidVvMovieId $input $output $dateStart
$hadoop fs -rm -r $hdfs$dateStart"2TodayvvHistory"
$hadoop fs -cp $output/part-r-00000 $hdfs$dateStart"2TodayvvHistory" 
#rm $dataPth$dateStart"2TodayvvHistory"
#$hadoop fs -get $hdfs$dateStart"2TodayvvHistory"  $dataPth
$hadoop fs -rm -r $output
#$hadoop fs -rm -r $hdfs$dateStart"2TodayvvHistory"

