
date=`date -d "1 days ago" +%m%d`

group=$1 ###### 输入组别标志 格式： 字母：标志码
#有localPredPth 目录 和localPredPth1 两个目录注意选择和设置
grpflag=${group:0:1}
localPredPth=$2 ##  本地/data/tvapk/cuiliqing/cuiliqing/下目录，用来存放预测所需的数据，包括
#model，#featuresIdx.txt personalLikes movieItemFeatures
jar="model2sort.jar"
hdfs="/user/tvapk/cuiliqing/"
dataPth="/data/tvapk/cuiliqing/cuiliqing/"
shPath=/home/tvapk/run_sh/cuiliqing/
hadoop="/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop"

cache=$hdfs"predictCache"

input="/user/tvapk/cuiliqing/predictInput"

output=$hdfs"predictOutput"

#dateInput=$date
#export dateInput
cd /home/tvapk/run_sh/handle_log/temp
## model label 第一位是0 flag=0; 若第二位是1，则flag＝1；
#sed -n '7,${modeltotRow}p' $dataPth$localPredPth/model | awk '{print NR,$1}' > $dataPth$localPredPth/wei.tx
#可能不支持'7,${modeltotRow}p'内部引入变量？
$hadoop fs -rm -r /user/tvapk/cuiliqing/recList
$hadoop jar grecommends.jar  PersonalRecommend.GetFileterMovies  /user/tvapk/peichao/TV/movieper/20160420/data $output/ /user/tvapk/cuiliqing/recList
$hadoop fs -getmerge /user/tvapk/cuiliqing/recList/part-* $dataPth$grpflag$date"allGuidPred.txt"

nohup java -cp /data/tvapk/rec/offlineserver-release-0.1.2.jar com.dianshijia.offlineserver.OfflinePersonalToMongos /data/tvapk/cuiliqing/cuiliqing/$grpflag$date"allGuidPred.txt"
