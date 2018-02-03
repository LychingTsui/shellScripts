#!
#vvdata="0801"
showdata="0803.txt"
pred="preddata"
#dataArv="2017"$vvdata/${vvdata}".txt"
jar="/home/tvapk/run_sh/cuiliqing/preddata.jar"
input="/user/tvapk/cuiliqing/input/"
output="/user/tvapk/cuiliqing/test"
hdfs="/user/tvapk/cuiliqing/"
movieFeat="movieItemFeatures"
showPath="/data/tvapk/show/" #####
#vvPath="/user/tvapk/peichao/TV/movieper/20160420/vvlog/"
hadoop="/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop"
personlLikes="personalLikes"
$hadoop fs -rm -r $input$showdata
$hadoop fs -put $showPath$showdata  $input
#$hadoop fs -rm -r $input/$vvdata
#$hadoop fs -cp $vvPath$dadaArv  $input/$vvdata
#$hadoop fs -rm -r $input/$showdata
#$hadoop jar $jar PersonalRecommend.GetMovieNotIncludeofShowVv $vvPath$dataArv  $output $hdfs$movieFeat
#tmpfile="tmp"
#$hadoop fs -rm -r $hdfs$tmpfile
#$hadoop fs -cp $output/part-r-00000  $hdfs$tmpfile
#$hadoop fs -rm -r $output
cache="cache"
#$hadoop fs -rm -r $hdfs$cache
#$hadoop fs -mkdir $hdfs$cache 
#$hadoop fs -cp $hdfs$moviefeat $hdfs$cache/part-r-00000 
#$hadoop fs -cp $hdfs$personalLikes $hdfs$cache/part-r-00001
$hadoop jar $jar PersonalRecommend.ItemsRecommendByModel  $input $output $hdfs$cache
#$hadoop fs -rm -r $hdfs$tmpfile
$hadoop fs -rm -r $input/$showdata
$hadoop fs -cp $output/part-r-00000 $hdfs$pred 
$hadoop fs -rm -r $output
dataSavePath="/data/tvapk/cuiliqing/cuiliqing/" 
$hadoop fs -get $hdfs$pred $dataSavePath
$hadoop fs -rm -r $hdfs$pred
