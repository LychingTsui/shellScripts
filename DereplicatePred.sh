
showdataFile="0815.txt"     

dataPath="/data/tvapk/cuiliqing/cuiliqing/"
model="model"
input1=${dataPath}$model  # model文件

featId="featuresIdx.txt"
input2=${dataPath}${featId}

userLike="personalLikes"
input3=$dataPath${userLike}

movFeatFile="movieItemFeatures"
input5=$dataPath${movFeatFile}

input7=200  # topk设置阈值

jarName1="Features.jar"
jarName2="model-1.0-SNAPSHOT.jar"
jarPath="/home/tvapk/run_sh/cuiliqing/"
showdataPath="/data/tvapk/show/"
vvdataPath="/user/tvapk/peichao/TV/movieper/20160420/vvlog"
dataArv=${showdataFile:0:4}
hdfsPath="/user/tvapk/cuiliqing/"
hadoop="/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop"

output="/user/tvapk/cuiliqing/test"

localOut="outPred"${dataArv}

rm ${dataPath}${localOut}
$hadoop fs -rm -r $output

# 获取最近半年的观看历史（程序设置的是最近半年的观看历史）
$hadoop jar ${jarPath}${jarName1} PersonalRecommend.GetUidVvMovieId $vvdataPath $output
$hadoop fs -rm -r ${hdfsPath}vvHistory
$hadoop fs -cp $output/part-r-00000 ${hdfsPath}vvHistory
$hadoop fs -rm -r $output

rm ${dataPath}vvHistory
$hadoop fs -get  ${hdfsPath}vvHistory $dataPath
input6=${dataPath}vvHistory 

# 获取其中一天的show 用户guid
$hadoop fs -rm -r $hdfsPath$showdataFile
$hadoop fs -put ${showdataPath}${showdataFile} $hdfsPath
$hadoop jar ${jarPath}${jarName1} PersonalRecommend.GetDaliyShowGuid $hdfsPath$showdataFile $output
$hadoop fs -rm -r ${hdfsPath}${dataArv}"guid"
$hadoop fs -cp $output/part-r-00000 ${hdfsPath}${dataArv}"guid"
$hadoop fs -rm -r $output

rm $dataPath${dataArv}"guid"
$hadoop fs -get ${hdfsPath}${dataArv}"guid" $dataPath
input4=$dataPath${dataArv}"guid" 

#对观看历史帅出 不做推荐
java -Xms4096m -Xmx4096m -cp ${jarPath}${jarName2} predict.DereplicatePred $input1  $input2 $input3 $input4 $input5 $input6 $input7  $localOut 

