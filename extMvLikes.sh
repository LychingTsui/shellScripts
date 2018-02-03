
read -p "please input 用户偏好label截取长度：(默认cutOff＝25)       " cutOff      #输入用户偏好label截取长度    
input="/user/tvapk/peichao/TV/movieper/20160420/tagsarg/*"
output="/user/tvapk/cuiliqing/test"
jarPath="/home/tvapk/run_sh/cuiliqing/"
jarName="Features.jar"

hadoop="/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop"
hdfs="/user/tvapk/cuiliqing/"
localPath="/data/tvapk/cuiliqing/cuiliqing/"
$hadoop fs -rm -r $output
$hadoop fs -rm -r ${hdfs}movie 
$hadoop fs -mkdir ${hdfs}movie   ##存储电影的act direct movieTags 文件
# 获取  /user/tvapk/peichao/TV/movieper/20160420/tagsarg/＊ 所有电影中用作features Key的act 文件
$hadoop jar ${jarPath}${jarName} com.qiguo.tv.movie.featuresCollection.CollectMovieFeature_actor $input $output 
$hadoop fs -rm -r ${hdfs}movie/act
$hadoop fs -get $output/part-r-00000 ${localPath}
$hadoop fs -rm -r $output

rm ${localPath}act   
#在本地路径下为act文件每行添加t1标签，为做缓存文件输入做识别用 t2 t3下同 同样作用
sed 's/^/t1&/g' ${localPath}part-r-00000  > ${localPath}act
actTotal=`cat ${localPath}act | wc -l`   #统计act key的长度，由于锁定 不同的key 对应的id索引
rm ${localPath}part-r-00000 
$hadoop fs -put ${localPath}act ${hdfs}movie/
 #获取电影用作features Key 的direct 
$hadoop jar ${jarPath}${jarName} com.qiguo.tv.movie.featuresCollection.CollectMovieFeature_director  $input $output
$hadoop fs -rm -r ${hdfs}movie/direct
$hadoop fs -get $output/part-r-00000 ${localPath}
$hadoop fs -rm -r $output

rm ${localPath}direct
#加t2 标签 作用同t1一样
sed 's/^/t2&/g' ${localPath}part-r-00000  > ${localPath}direct
directTotal=`cat ${localPath}direct | wc -l`
rm ${localPath}part-r-00000
$hadoop fs -put ${localPath}direct  ${hdfs}movie/
# 获取电影的Tags 中用作 feature Key的tags
$hadoop jar ${jarPath}${jarName} com.qiguo.tv.movie.featuresCollection.GetMovieFeatures_tags  $input $output
$hadoop fs -rm -r ${hdfs}movie/movieTags
$hadoop fs -get $output/part-r-00000 ${localPath}
$hadoop fs -rm -r $output

rm ${localPath}movieTags
sed 's/^/t3&/g' ${localPath}part-r-00000  > ${localPath}movieTags
movieTags=`cat ${localPath}movieTags | wc -l`
rm ${localPath}part-r-00000
$hadoop fs -put ${localPath}movieTags  ${hdfs}movie/
# features key 拼接后 映射到连续的id索引
directStartId=$[actTotal+1]
mvTagsStartId=$[actTotal+directTotal+1]
likesTagsStartId=$[actTotal+directTotal+movieTags+2+1]
mvTagsIdxEnd=$[actTotal+directTotal+movieTags]
personalLikesIdStart=$[actTotal+directTotal+movieTags*2+2+1]
########### 获取特征id 区间段的起末id索引 
rm ${localPath}featuresIdx.txt
touch  ${localPath}featuresIdx.txt
echo "direct起始Id: $directStartId" >> ${localPath}featuresIdx.txt
echo "movieTags起始Id: $mvTagsStartId" >> ${localPath}featuresIdx.txt 
echo "joinLikeTags起始Id: $likesTagsStartId" >> ${localPath}featuresIdx.txt
echo "user偏好features起始Id: $personalLikesIdStart" >> ${localPath}featuresIdx.txt 
############
#一条电影数据 映射成一条movieId：[id:val ...] 格式的数据
$hadoop jar ${jarPath}${jarName} com.qiguo.tv.movie.featCollection.GetMovieItem_features2 $input $output ${hdfs}movie $directStartId $mvTagsStartId $mvTagsIdxEnd
movieItemFets="movieItemFeatures"
$hadoop fs -rm -r ${hdfs}${movieItemFets}
$hadoop fs -cp $output/part-r-00000 ${hdfs}${movieItemFets} 
$hadoop fs -rm -r $output
#rm ${localPath}${movieItemFeatures}
#$原始用户的偏好数据文件
userLikes="/user/tvapk/peichao/personas/userlabel/*"
# 获得用户偏好label 中用作特征key的label （截取长）
$hadoop jar ${jarPath}${jarName} com.qiguo.tv.movie.featCollection.GetPersonalLikesKey $userLikes $output $cutOff
$hadoop fs -rm -r ${hdfs}personalLikesKey
$hadoop fs -cp $output/part-r-00000 ${hdfs}personalLikesKey 
$hadoop fs -rm -r $output

$hadoop fs -rm -r ${hdfs}movieLikesCache
$hadoop fs -mkdir ${hdfs}movieLikesCache
$hadoop fs -cp ${hdfs}movie/movieTags ${hdfs}movieLikesCache/part-r-00000
$hadoop fs -cp ${hdfs}personalLikesKey ${hdfs}movieLikesCache/part-r-00001
# 获取用户偏好key 对应的特征值 格式 guid [id:val....] y已处理好电影tags和偏好label重叠交叉除的特征 用户偏好label里的key
# 如存在与movieTags 里 则占为交叉特征id ; 1  待与某一个特定电影拼接后 才确定交叉部分特征的最终值
$hadoop jar ${jarPath}${jarName} com.qiguo.tv.movie.featCollection.GetPersonalLikesFeatures $userLikes $output ${hdfs}movieLikesCache $likesTagsStartId $personalLikesIdStart $cutOff

$hadoop fs -rm -r ${hdfs}personalLikes
$hadoop fs -cp $output/part-r-00000 ${hdfs}personalLikes 
$hadoop fs -rm -r $output
# ext1.sh 需要引用到的变量
export mvTagsStartId
export likesTagsStartId
export personalLikesIdStart
movieItemFeatures=${hdfs}${movieItemFets}
export movieItemFeatures
sh ${jarPath}ext1.sh
