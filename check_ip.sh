#!/bin/bash
# Check actual IP address from ISP
# And actualize the web site domain name
# 
# Parameters
LOGPATH="/var/log/checkip"
LOGFILE="/var/log/checkip/checkip.log"
IPFILE="/var/log/checkip/ipAddress.log"
OVH_DNS=""
IPTOCHECKWEBACCESS="8.8.8.8"
GETPUBLICADDRESS="https://ipinfo.io/ip"
DESTINATIONEMAIL="xxx@xxx.xxx"

# Functions
check_folder_exist() {
  if [ ! -d $1 ]; then
    create_folder $1
    chown fred:fred $1
    chmod 777 $1
  fi
}

create_folder() {
  CREATE_FOLDER= `sudo mkdir $1`
  chown fred:fred $1
  chmod 777 $1
}

check_file_exist() {
  if [ ! -f $1 ]; then
    CREATE_FILE= `sudo touch $1`
    chown fred:fred $1
    chmod 777 $1
  fi
  return 0
}

create_file() {
  CREATE_FILE="sudo echo '' >> $1"
  chown fred:fred $1
  chmod 777 $1
}

# write logfile msg $1 path $2 pathfile $3
write_log(){
  echo "$(dateTime_generator) logger: $1" >> $3
}

# write logIPfile msg $1 path $2 pathfile $3
write_ipAddress(){
  echo "$(dateTime_generator) $1" >> $3
}


dateTime_generator(){
  echo "$(date +"%Y/%m/%d %T")"
}

check_web_access() {
  PINGIP=`ping -c1 $1 -n 1 > /dev/null 2>&1`
  if [ ! $? = 0 ]; then
    write_log "ERROR Web acces seems to be down => cant reach webip: $1" $LOGPATH $LOGFILE
    return 1
  else
    write_log "INFO Web access OK => webip $1 reached" $LOGPATH $LOGFILE
    return 0
  fi
}

get_my_ip() {
  MYIP=`curl -s $1 2>&-`
  if checkNullChain "$MYIP" -eq 0 ; then 
    if lookingForAGivenRegexInAString "404" "$MYIP" -eq 0 ; then	    
	  write_log "ERROR cant get public ip from : $1" $LOGPATH $LOGFILE
      return 1
    else
	  return 0
	fi
  else
	  write_log "ERROR cant get public ip from : $1" $LOGPATH $LOGFILE
   return 1
  fi
}

checkNullChain() {
  if [ -z "$1" ]; then
	return 1
  else
	return 0
  fi 
}


# return boolean if a given regex is found in a given text
# givenRegex $1 and givenText $2
lookingForAGivenRegexInAString(){
  test=$(echo "$2" | grep -oP "$1")
  if [ ! -z "$test" ]; then
    if [ $test = "404" ]; then  
      return 0
    else
      return 1
    fi
  else
	return 1
  fi
}

exit_program() {
  write_log "ERROR $1" $LOGPATH $LOGFILE
  exit 1
}

read_last_line_from_log(){
  return 'tail -n 1 $1'
}

compare_last_publicIp_and_actual_publicIp() {
  LASTIPFROMFILE= read_last_line_from_log $IPFILE
  echo $LASTIPFROMFILE
  # if [ $LASTIPFROMFILE = $MYIP]
}

send_email(){
  echo "Mail du raspberrypi" | mail -s "Ip Info" ricodoby@hotmail.com
}

# ===============================================
# Logic
# ===============================================
# Check folder & files exist
check_folder_exist $LOGPATH
check_file_exist $LOGFILE
check_file_exist $IPFILE

# Check_web_access $IPTOCHECKWEBACCESS
if [ $check_web_access $IPTOCHECKWEBACCESS = 0 ] ; then
  exit_program "No Internet access"
fi

# Get Public IP
if get_my_ip $GETPUBLICADDRESS -eq 0; then
  echo "myip $MYIP"
  write_ipAddress $MYIP $LOGPATH $IPFILE
else
  exit_program "Get_Public_Ip => KO"
fi



#compare_last_publicIp_and_actual_publicIp
#EOF
