>/tmp/uniqtime.lst
for i in `cat s01-deploy-hypershift-full-detail.cast |awk -F'.' '{print $1}'`
do
   if [[ "$i" == [* ]];then
	   echo ${i}>>/tmp/uniqtime.lst
   fi
done

cat /tmp/uniqtime.lst | sed  "s/\[//">/tmp/nums.lst
totallines=`wc -l /tmp/nums.lst| awk '{print $1}'`
initline=0
firstvalue=10
>/tmp/steps.lst
while [ $initline -lt $totallines ]
do

   nextline=$(( $initline+1 ))
   nextvalue=`sed -n "${nextline}p" /tmp/nums.lst`
   step=$(( ${nextvalue}-${firstvalue} ))
   echo $step>>/tmp/steps.lst
   initline=$(( $initline+1 ))
   firstvalue=$nextvalue
done
cat /tmp/steps.lst

i=1
>/tmp/newtimeindex.lst
for step in `cat /tmp/steps.lst`
do
    echo step is $step
    if [ $step -gt 8 ];then
	    i=$(( $i+8  ))
    elif [ $step -eq 0 ];then
	    i=$i
    else
            i=$(( $i+$step  ))
    fi
    echo $i>>/tmp/newtimeindex.lst
done
cat /tmp/newtimeindex.lst


wc -l /tmp/newtimeindex.lst
wc -l /tmp/uniqtime.lst
