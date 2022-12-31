MODIFIED_FILE=$1

if [ $# -ne 1 ];then
   echo "$0: asciiema cast filename"
   exit 1
fi


DATE=`date "+%y%m%d%H%H%S"`
cp $MODIFIED_FILE ${MODIFIED_FILE}.${DATE}
>/tmp/timeSec.lst
for timeSec in `cat $MODIFIED_FILE |awk -F'.' '{print $1}'|awk -F'.' '{print $1}' |grep '^\['|sed  "s/\[//"`
do
    echo $timeSec >>/tmp/timeSec.lst 
done

TOTAL_LINES=`wc -l /tmp/timeSec.lst| awk '{print $1}'`
INITIAL_LINES=0
PREV_VALUE=`head -1 /tmp/timeSec.lst`
>/tmp/timeSteps.lst
while [ $INITIAL_LINES -lt $TOTAL_LINES ]
do

   NEXT_LINE=$(( $INITIAL_LINES+1 ))
   NEXT_VALUE=`sed -n "${NEXT_LINE}p" /tmp/timeSec.lst`
   step=$(( ${NEXT_VALUE}-${PREV_VALUE} ))
   echo $step>>/tmp/timeSteps.lst
   INITIAL_LINES=$(( $INITIAL_LINES+1 ))
   PREV_VALUE=$NEXT_VALUE
done

i=1
>/tmp/newTimeSec.lst
for step in `cat /tmp/timeSteps.lst`
do
    if [ $step -gt 8 ];then
	    i=$(( $i+8  ))
    elif [ $step -eq 0 ];then
	    i=$i
    else
            i=$(( $i+$step  ))
    fi
    echo $i>>/tmp/newTimeSec.lst
done

wc -l /tmp/timeSec.lst
wc -l /tmp/newTimeSec.lst

#Still need to improve
#Replace from second line
#i=2
#for newTimeIndex in `cat /tmp/newTimeSec.lst`
#do
#   sed -i "${i}{s;^\[.*\.;\[${newTimeIndex}.;}" $MODIFIED_FILE
#   i=$(( $i+1 ))
#done
