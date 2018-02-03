
#input="/user/tvapk/peichao/TV/movieper/20160420/personasMaxmin/*"
input="/user/tvapk/peichao/personas/userlabel "
output="/user/tvapk/cuiliqing/test"
jarPath="/home/tvapk/run_sh/cuiliqing/"
jarName="Features.jar"

hdfsPath="/user/tvapk/cuiliqing/"
dataPath="/data/tvapk/cuiliqing/cuiliqing/"
hadoop="/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop"

$hadoop fs -rm -r ${output}
$hadoop jar ${jarPath}${jarName} com.qiguo.tv.movie.featCollection.GetPersonalLikesKey  $input $output
$hadoop fs -cp ${output}/part-r-00000  ${hdfsPath}likeKeys1
rm ${dataPath}likeKeys1
$hadoop fs -get ${hdfsPath}likeKeys1  ${dataPath}
$hadoop fs -rm -r $output
$hadoop fs -cp ${hdfsPath}likeKeys1 ${hdfsPath}cache1/part-r-00001
$hadoop jar ${jarPath}${jarName} com.qiguo.tv.movie.featCollection.GetPersonalLikesFeatures $input $output ${hdfsPath}cache1
$hadoop fs -rm -r ${hdfsPath}personalLikesV1
$hadoop fs -cp ${output}/part-r-00000  ${hdfsPath}personalLikesV1
$hadoop fs -rm -r $output
rm ${dataPath}personalLikesV1
$hadoop fs -get ${hdfsPath}personalLikesV1 ${dataPath}


