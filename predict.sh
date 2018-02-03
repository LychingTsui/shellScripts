
date=`date -d "1 days ago" +%m%d`

group="G:207" ###### 输入组别标志 格式： 字母：标志码
#有localPredPth 目录 和localPredPth1 两个目录注意选择和设置
grpflag=${group:0:1}
localPredPth=predByModel2 ##  本地/data/tvapk/cuiliqing/cuiliqing/下目录，用来存放预测所需的数据，包括
#model，#featuresIdx.txt personalLikes movieItemFeatures
jar=Predict.jar
hdfs=/user/tvapk/cuiliqing/
dataPth=/data/tvapk/cuiliqing/cuiliqing/
shPath=/home/tvapk/run_sh/cuiliqing/
hadoop=/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop

cache=$hdfs"predictCache"
$hadoop fs -rm -r $cache
$hadoop fs -mkdir $cache

input=/user/tvapk/cuiliqing/predictInput
$hadoop fs -rm -r $input
$hadoop fs -mkdir $input

output=$hdfs"predictOutput"

#dateInput=$date
#export dateInput
/usr/bin/sh ${shPath}getguid.sh

## model label 第一位是0 flag=0; 若第二位是1，则flag＝1；
flag=`sed -n '3p' $dataPth$localPredPth/model |awk '{print $2}'`
echo $flag  
sed 's/^/uid&/g' ${dataPth}$date"guid.txt" > ${dataPth}"guid.txt"  #对 guid 文件加头部标记，便于缓存读入拣出
$hadoop fs -rm -r $cache/"guid.txt"
$hadoop fs -put ${dataPth}"guid.txt" $cache
rm ${dataPth}"guid.txt"
modeltotRow=`cat $dataPth$localPredPth/model | wc -l`
weitot=$[modeltotRow-6]
cat $dataPth$localPredPth/model |tail -$weitot |awk '{print NR,$1}' > $dataPth$localPredPth/wei.txt
#sed -n '7,${modeltotRow}p' $dataPth$localPredPth/model | awk '{print NR,$1}' > $dataPth$localPredPth/wei.tx
#可能不支持'7,${modeltotRow}p'内部引入变量？
sed 's/^/w&/g' $dataPth$localPredPth/wei.txt > $dataPth$localPredPth/wei1.txt #对model文件取出权重数据
$hadoop fs -put $dataPth$localPredPth/wei1.txt $cache
$hadoop fs -put $dataPth$localPredPth/featuresIdx.txt $cache
$hadoop fs -put $dataPth$localPredPth/movieItemFeatures $cache
$hadoop fs -put $dataPth$localPredPth/personalLikes $input
$hadoop fs -rm -r $output
$hadoop jar ${shPath}$jar PersonalRecommend.ItemsRecommendByModel2  $input $output $cache $flag $group 
$hadoop fs -get $output/part-r-00000 $dataPth 
rm $dataPth$grpflag$date"allGuidPred.txt"   ##grpflag 组别标志码
cp ${dataPth}part-r-00000 $dataPth$grpflag$date"allGuidPred.txt"
rm ${dataPth}part-r-00000
$hadoop fs -rm -r $output
