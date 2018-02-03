## java VM内存设置已经到最大值，注意修改
trainFile="train.txt"
testFile="test.txt"
#testDaRows=`cat ${path}testFile | wc -l` # 用于调用Linear.predict，在此处不需要
modelName="model"
path="/data5/cuiliqing/"  #数据文件所在路径，注意修改
nohup java  -Xms11264m -Xmx11264m  -cp ${path}liblinear-1.95.jar de.bwaldvogel.liblinear.Train -s 7 -c 7  -e 0.001  ${path}${train}  ${path}${modelName} > trainLog.log 2>& 1 &
