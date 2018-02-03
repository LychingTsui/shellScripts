yesterday=`date -d "2 days ago" +%m%d`
file=${yesterday}allGuidPred.txt
nohup java -cp /data/tvapk/rec/offlineserver-release-0.1.2.jar com.dianshijia.offlineserver.OfflinePersonalToMongos /data/tvapk/cuiliqing/cuiliqing/$file &
