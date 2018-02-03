# !/bin/sh
. /etc/profile
# 路径定义缩写

date=`date -d "1 days ago" +%m%d`
hdfs=/user/tvapk/cuiliqing
dataPath=/data/tvapk/cuiliqing/cuiliqing
hadoop=/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop
shellPath=/home/tvapk/run_sh/cuiliqing

# (1) 上传模型的计算出的文件（权重文件等）
$hadoop fs -rm -r $hdfs/predictCache/*

# (2) 提取需要预测的用户的guid
$hadoop fs -rm -r $hdfs/predictInput
$hadoop fs -mkdir $hdfs/predictInput

dateInput=$date
export dateInput
/usr/bin/sh $shellPath/getguid.sh 

# (3) 获取model文件中第一位label的值，第一位是0 flag=0; 若第二位是1，则flag＝1
flag=`sed -n '3p' $dataPath/predByModel/model | awk '{print $2}'`
#echo $flag
# (3-1) 文件的每一行的行头加入uid字符，区分后续缓存文件
rm $dataPath/guid.txt
sed 's/^/uid&/g' $dataPath/$date"guid.txt" > $dataPath/guid.txt

#$hadoop fs -put $dataPath/guid.txt $hdfs/predictCache
countModelRow=`cat $dataPath/predByModel/model |wc -l`
countWeight=$[countModelRow-6]
rm $dataPath/predByModel/weight.txt
rm $dataPath/predByModel/weightStep.txt
cat $dataPath/predByModel/model |tail -$countWeight |awk '{print NR,$1}' > $dataPath/predByModel/weight.txt
sed 's/^/w&/g' $dataPath/predByModel/weight.txt > $dataPath/predByModel/weightStep.txt
$hadoop fs -put $dataPath/predByModel/weightStep.txt $hdfs/predictCache
$hadoop fs -put $dataPath/predByModel/featuresIdx.txt $hdfs/predictCache
$hadoop fs -put $dataPath/predByModel/movieItemFeatures $hdfs/predictCache
$hadoop fs -put $dataPath/predByModel/personalLikes $hdfs/predictInput
$hadoop fs -rm -r $hdfs/predictOutput
$hadoop jar $shellPath/Predict.jar PersonalRecommend.ItemsRecommendByModel $hdfs/predictInput $hdfs/predictOutput $hdfs/predictCache $flag
$hadoop fs -get $hdfs/predictOutput/part-r-00000 $dataPath
rm $dataPath/$date"allGuidPred.txt"
cp $dataPath/part-r-00000 $dataPath/$date"allGuidPred.txt"
rm $dataPath/part-r-00000

