#输入： vv日志数据 show日志数据 缓存文件：
#输出： 排序后的guid_0／1_itemfeaturesSet
#      join 内的part-r-00000 是用户偏好特征，注意更新  
showdataFile="0802.txt"     # input_1
vvdatafile="20170802"  #input_2
# 记得更新jar包
jarName="Features.jar"
movieItemFeatPath="/user/tvapk/cuiliqing/movieItemFeatures"

jarPath="/home/tvapk/run_sh/cuiliqing/"
showdataPath="/data/tvapk/show/"

dataArv=${showdataFile:0:4}
hdfsPath="/user/tvapk/cuiliqing/"
hadoop="/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop"
$hadoop fs -rm -r ${hdfsPath}${showdataFile}
$hadoop fs -put ${showdataPath}${showdataFile} $hdfsPath
vvdataPath="/user/tvapk/peichao/TV/movieper/20160420/vvlog/"

input=$hdfsPath$showdataFile
output="/user/tvapk/cuiliqing/test"
$hadoop fs -rm -r $output
cacheFile=$vvdataPath$vvdatafile
$hadoop jar ${jarPath}${jarName}  com.qiguo.tv.movie.featCollection.GetGuidItemLabel01 $input $output $cacheFile
$hadoop fs -rm -r $input
tmpfileName="guid_01_itemid"$dataArv

$hadoop fs -rm -r ${hdfsPath}$tmpfileName
$hadoop fs -cp ${output}/part-r-00000 ${hdfsPath}$tmpfileName
$hadoop fs -rm -r $output


$hadoop jar ${jarPath}${jarName}  com.qiguo.tv.movie.featCollection.GetCombineGuid_Item_label01 ${hdfsPath}$tmpfileName  $output $movieItemFeatPath 
#$hadoop fs -rm -r ${hdfsPath}$tmpfileName
#filename="guid_01_itemfeaturs"
$hadoop fs -rm -r ${hdfsPath}join/part-r-00001 #####某天的用户行为数据  part-r-00000 是用户偏好特征注意更新
$hadoop fs -cp ${output}/part-r-00000 ${hdfsPath}join/part-r-00001 
$hadoop fs -rm -r $output

$hadoop jar ${jarPath}${jarName} com.qiguo.tv.movie.featCollection.GetCombineMovieAndLikesFeatures ${hdfsPath}join  $output 

$hadoop fs -cp $output/part-r-00000 ${hdfsPath}${dataArv}
$hadoop fs -rm -r $output 
dataSavePath="/data/tvapk/cuiliqing/cuiliqing/"
$hadoop fs -get ${hdfsPath}${dataArv} $dataSavePath
$hadoop fs -rm -r ${hdfsPath}${dataArv} 
