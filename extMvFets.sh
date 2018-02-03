
input="/user/tvapk/peichao/TV/movie/20160420/tagsarg/*"
output="/user/tvapk/run_sh/cuiliqing/test"
jarPath="/home/tvapk/run_sh/cuiliqing/"
jarName="Features_notypedate.jar"
cacheInput="/user/tvapk/run_sh/cuiliqing/actDirectAreaSet.txt"
hadoop="/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop"
hdfs="/user/tvapk/run_sh/cuiliqing/"
localPath="/data/tvapk/cuiliqing/cuiliqing/"
$hadoop fs -rm -r $output

$hadoop jar ${jarPath}${jarName} com.qiguo.tv.movie.featCollection.GetMovieItem_features2 $input $output $cacheInput
movieItemFeatures="movieItemFets_notypedate"
$hadoop fs -rm -r ${hdfs}${movieItemFeatures}
$hadoop fs -cp $output/part-r-00000 ${hdfs}${movieItemFeatures} 
$hadoop fs -rm -r $output
rm ${localPath}${movieItemFeatures}
$hadoop fs -get ${hdfs}${movieItemFeatures} ${localPath} 

