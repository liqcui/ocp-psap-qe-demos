#!/bin/bash
print_stdout_withcolor()
{  
   COLOR_TYPE=$1
   COLOR_TYPE=`echo $COLOR_TYPE | tr [A-Z] [a-z]`
   TextString=$2
   IF_BOLD=$3
   case $COLOR_TYPE in
	   black) 
               COLOR_INDEX=30
		   ;;
	   red) 
               COLOR_INDEX=31
		   ;;
	   green) 
               COLOR_INDEX=32
		   ;;
	   yellow) 
               COLOR_INDEX=33
		   ;;
	   blue) 
               COLOR_INDEX=34
		   ;;
	   magenta) 
               COLOR_INDEX=35
		   ;;
	   cyan) 
               COLOR_INDEX=36
		   ;;
	   white) 
               COLOR_INDEX=37
		   ;;
	   reset) 
               COLOR_INDEX=0
		   ;;
	   *) 
               echo "invalid parameter"
	       exit 1
		   ;;
   esac
   if [[ $IF_BOLD == "bold" ]];then
       BOLD='\033[1m'
       echo -e "\e[1;${COLOR_INDEX}m${BOLD}${TextString}\e[0m"
   else
       echo -e "\e[1;${COLOR_INDEX}m${TextString}\e[0m"
   fi
}

display_and_run() {
   red="\e[31m"
   cyan="\e[36m"
   white="\e[37m"
   reset="\e[0m"
   echo -e "$white$ $cyan" | tr -d '\n'
   for i in $1
   do
         echo -e "$i " | tr -d '\n'
	 sleep 0.25
   done
   printf "$reset"
   read -r
   eval $1
   read
}


show_prompt_text()
{
 COLOR_TYPE=$1
 case $COLOR_TYPE in
	   black) 
               COLOR_INDEX=30
		   ;;
	   red) 
               COLOR_INDEX=31
		   ;;
	   green) 
               COLOR_INDEX=32
		   ;;
	   yellow) 
               COLOR_INDEX=33
		   ;;
	   blue) 
               COLOR_INDEX=34
		   ;;
	   magenta) 
               COLOR_INDEX=35
		   ;;
	   cyan) 
               COLOR_INDEX=36
		   ;;
	   white) 
               COLOR_INDEX=37
		   ;;
	   reset) 
               COLOR_INDEX=0
		   ;;
	   *) 
               echo "invalid parameter"
	       exit 1
		   ;;
 esac
 echo
 for i in $2
 do
    echo -e "\e[1;${COLOR_INDEX}m${i}\e[0m " | tr -d '\n'
    sleep 0.2
 done
 echo -e "\n"
 #echo -e "\e[0m"
 #read
}

repeatedCharNTimes()
{
  REPEAT_CHAR=$1
  REPEAT_TIMES=$2
  seq -s${REPEAT_CHAR} ${REPEAT_TIMES} |tr -d '[:digit:]'
}

formatStdOutString()
{ 
  FORMAT_STRING=$1
  TOTAL_CHAR_NUM=$2
  STRING_NUM=`echo "$FORMAT_STRING" |wc -m`  
  TOTAL_SPACE_NUM=$(( $TOTAL_CHAR_NUM - $STRING_NUM ))
  TOTAL_SPACE_NUM=$(( $TOTAL_SPACE_NUM - 4 ))
  MOD=$(( $TOTAL_SPACE_NUM%2 ))
  SPACE_NUM=$(( $TOTAL_SPACE_NUM/2 ))
  if [ $MOD -eq 0 ];then
  	PRE_SPACE_NUM=$SPACE_NUM
        POST_SPACE_NUM=$SPACE_NUM
  else
        PRE_SPACE_NUM=$SPACE_NUM
	POST_SPACE_NUM=$(( $SPACE_NUM+1 ))
  fi
  echo "##`printf %${PRE_SPACE_NUM}s`${FORMAT_STRING}`printf %${POST_SPACE_NUM}s`##"
}

formatStdOutBeginEndString()
{ 
  FORMAT_STRING=$1
  TOTAL_CHAR_NUM=$2
  STRING_NUM=`echo "$FORMAT_STRING" |wc -m`  
  TOTAL_SPACE_NUM=$(( $TOTAL_CHAR_NUM - $STRING_NUM ))
  TOTAL_SPACE_NUM=$(( $TOTAL_SPACE_NUM - 36 ))
  MOD=$(( $TOTAL_SPACE_NUM%2 ))
  SPACE_NUM=$(( $TOTAL_SPACE_NUM/2 ))
  if [ $MOD -eq 0 ];then
  	PRE_SPACE_NUM=$SPACE_NUM
        POST_SPACE_NUM=$SPACE_NUM
  else
        PRE_SPACE_NUM=$SPACE_NUM
	POST_SPACE_NUM=$(( $SPACE_NUM+1 ))
  fi
  echo "==================`printf %${PRE_SPACE_NUM}s`${FORMAT_STRING}`printf %${POST_SPACE_NUM}s`=================="
}

