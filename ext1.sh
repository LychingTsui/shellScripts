#本sh 文件是在extMVLikes  执行结束后获得电影的特征文件 和 用户偏好key文件后
# 此文件获取一天或几天用户的show数据和vv数据，第一个MR 获得用户对电影的行为 分为0和1 格式：guid 0/1 movieId
#第二个Mapreduce 把movieId 换成对成movieId的特征值列表
#第三个Mapreduce  获得某一天用户偏好特征和电影及行为的拼接（中间mmovieTags和用户偏好label交叉的特征已处理完毕），输出的格式已是liblinear数据格式
dataInput="0915 0916 0917"
OLD_IFS="$IFS"
IFS=" "
arr=($dataInput)
IFS="$OLD_IFS"

jarName="Features.jar"
movieItemFeatPath=$movieItemFeatures   # 调用俄ext1.sh export 的变量

jarPath="/home/tvapk/run_sh/cuiliqing/"             
showdataPath="/data/tvapk/show/"

hdfsPath="/user/tvapk/cuiliqing/"                     
hadoop="/opt/hadoop/hadoop-2.6.0-cdh5.7.1/bin/hadoop"
vvdataPath="/user/tvapk/peichao/TV/movieper/20160420/vvlog/"
dataSavePath="/data/tvapk/cuiliqing/cuiliqing/"
rm -rf ${dataSavePath}dataSet        # 保存训练集测试集预留本的本地路径
mkdir ${dataSavePath}dataSet

for s in ${arr[@]}
do
    showdataFile="$s"".txt"           #showdata的文件名格式如  201708015.txt
    vvdatafile="2017""$s"             # vv 数据文件名格式20170815
    $hadoop fs -rm -r  ${hdfsPath}$s"tmpfile"
    $hadoop fs -mkdir  ${hdfsPath}$s"tmpfile" 
    dataArv=${showdataFile:0:4}        # 获取日期如 0802  作为文件的标志符

    $hadoop fs -rm -r ${hdfsPath}${showdataFile}
    $hadoop fs -put ${showdataPath}${showdataFile} $hdfsPath
   
    input=$hdfsPath$showdataFile
    output="/user/tvapk/cuiliqing/test"  # 输出路径
    $hadoop fs -rm -r $output
    cacheFile=$vvdataPath$vvdatafile
    # 第一个MapReduce 获得用户对电影的行为 分为0和1 格式：guid 0/1 movieId
    $hadoop jar ${jarPath}${jarName}  com.qiguo.tv.movie.featCollection.GetGuidItemLabel01 $input $output $cacheFile 
    $hadoop fs -rm -r $input
    tmpFile01="guid_01_itemid"$dataArv     # 中间结果数据文件 格式：guid 0/1 movieId 

    $hadoop fs -rm -r ${hdfsPath}$tmpFile01
    $hadoop fs -cp ${output}/part-r-00000 ${hdfsPath}$tmpFile01
    $hadoop fs -rm -r $output

    #  第二个MapReduce 把对应电影ID 换成 其对应的特征值 格式 guid 0/1 [featureId:val...]
    $hadoop jar ${jarPath}${jarName}  com.qiguo.tv.movie.featCollection.GetCombineGuid_Item_label01 ${hdfsPath}$tmpFile01  $output $movieItemFeatPath 
    $hadoop fs -mv ${hdfsPath}$tmpFile01 ${hdfsPath}$s"tmpfile"/  #中间结果保留路径 
    $hadoop fs -rm -r  ${hdfsPath}join
    $hadoop fs -mkdir ${hdfsPath}join 
    #$hadoop fs -rm -r ${hdfsPath}join/part-r-00000
    $hadoop fs -cp ${hdfsPath}personalLikes ${hdfsPath}join/part-r-00000 
    #$hadoop fs -rm -r ${hdfsPath}join/part-r-00001 #####某天的用户行为数据  part-r-00000 是用户偏好特征注意更新
    $hadoop fs -cp ${output}/part-r-00000 ${hdfsPath}join/part-r-00001
    $hadoop fs -mv ${output}/part-r-00000 ${hdfsPath}$s"tmpfile"/     #中间结果保留路径
    $hadoop fs -rm -r $output
    #第三个MapReduce   输出标准的Liblinear 格式数据待按比例分割训练测试集后 可参与训练测试
    $hadoop jar ${jarPath}${jarName} com.qiguo.tv.movie.featCollection.GetCombineMovieAndLikesFeatures ${hdfsPath}join $output $mvTagsStartId $likesTagsStartId $personalLikesIdStart

    $hadoop fs -cp $output/part-r-00000 ${hdfsPath}${dataArv}
    $hadoop fs -rm -r $output 
   
    rm -rf  $dataSavePath${dataArv}    # 本地预留保存路径
    $hadoop fs -get ${hdfsPath}${dataArv} $dataSavePath
    $hadoop fs -rm -r ${hdfsPath}${dataArv}

    lines=`cat ${dataSavePath}${dataArv} | wc -l`
    posTotal=`cat ${dataSavePath}${dataArv} | awk '$1==1.0' | wc -l`      #统计正例样本个数
    echo "正例样本总数： $posTotal"
    negTotal=`cat ${dataSavePath}${dataArv} | awk '$1==0.0' | wc -l`      # 统计负例样本个数
    echo "负例样本总数： $negTotal"


    posLineTest=$[posTotal/5]
    echo "正例测试样本数目： $posLineTest"
    posLineTrain=$[posTotal-posLineTest]
    echo "正例训练样本数目： $posLineTrain"
    negLineTest=$[negTotal/5]
    echo "负例测试样本数目； $negLineTest"
    negLineTrain=$[negTotal-negLineTest]
    echo "负例训练样本数目: $negLineTrain"

    # 按比例分割训练集 测绘集
    cat ${dataSavePath}${dataArv} | awk '$1==0.0' | head  -$negLineTrain >> ${dataSavePath}dataSet/train.txt
    cat ${dataSavePath}${dataArv} | awk '$1==0.0' | tail  -$negLineTest  >> ${dataSavePath}dataSet/test.txt
    cat ${dataSavePath}${dataArv} | awk '$1==1.0' | head  -$posLineTrain >> ${dataSavePath}dataSet/train.txt
    cat ${dataSavePath}${dataArv} | awk '$1==1.0' | tail  -$posLineTest >> ${dataSavePath}dataSet/test.txt

    echo "路径下 ${dataSavePath}dataSet/train.txt 训练样本数据文件生成"
    echo "路径下 ${dataSavePath}dataSet/test.txt 测试样本数据文件生成"

done



