#!/bin/sh

#
# Check actual IP address from ISP
# And actualize the web site domain name
# 

# Seqences
# Check Internet access
#	return
# Get actual ip address from ISP and set a ACTUAL_IP parameter
# Check if ip_file_histo exist
#	Return
# Check if ACTUAL_IP is present in ip_file_histo.txt
#	return
# If not exist add ACTUAL_IP in ip_file_histo.txt
#	retrun
# Add DateTime	ACTUAL_IP in ip_file_histo.txt
#	return
# Send ACTUAL_IP to web site domain name
#	return
# Send Email with informations
#	return
# LogsWriter
# Configure Logrotate

# Parameters
LOGPATH="/var/log/checkip"
LOGFILE="/var/log/checkip/checkip.log"
IPFILE="/var/log/checkip/ipAddress.log"
OVH_DNS=""
IPTOCHECKWEBACCESS="8.8.8.8"
GETPUBLICADDRESSE="https://ipinfo.io/ip"
DESTINATIONEMAIL="xxx@xxx.xxx"

# Functions
check_folder_exist() {
	if [ ! -f "$1"]; then
		create_folder $1
	fi
}

create_folder() {
	CREATE_FOLDER=`mkdir $1`
	if [ $? = 0 ]; then
		write_log "ERROR unable to create folder: $1"
	else
		write_log "INFO folder created: $1" $LOGPATH $LOGFILE
	fi 
}

check_file_exist(){
	if [ ! -f "$1" ];then
		touch $1
	fi
	if [ ! $? = 0 ]; then
		write_log "ERROR unable to create file: $1" $LOGPATH $LOGFILE
	else
		write_log "INFO file created: $1" $LOGPATH $LOGFILE
	fi
}

# write logfile msg $1 path $2 pathfile $3
write_log(){
	check_folder_exist $2
	check_file_exist $3
	echo dateTime_generator" $1" >> $3
}

dateTime_generator(){
	return date "+%y+%m+%d_+%T"
}

check_web_access() {
	ping -c1 $1
	if [ ! $? = 0]; then
		write_log "ERROR cant reach webip: $1" $LOGPATH $LOGFILE
		return 1
	else
		write_log "INFO webip $1 reached" $LOGPATH $LOGFILE
		return 0
	fi
}

get_my_ip(){
	MYIP=`curl "$1"`
	if [ ! $? = 0]; then
		write_log "ERROR cant get public ip from : $1" $LOGPATH $LOGFILE
		return 1
	else
		write_log "INFO public address: $MYIP" $LOGPATH $LOGFILE
		return 0
	fi
}

exit_program() {
	write_log "ERROR: $1" $LOGPATH $LOGFILE
	exit 1
}

read_last_line_from_log(){
	return (tail -n 1 $1)
}

compare_last_publicIp_and_actual_publicIp() {
	LASTIPFROMFILE= read_last_line_from_log $IPFILE
	echo $LASTIPFROMFILE
	# if [ $LASTIPFROMFILE = $MYIP]
}

send_email(){

}

# Logic
# Check internet access
if [ check_web_access = 1 ]; then
	exit_program "No Internet access"

if [ get_my_ip = 0 ]; then
	write_log $MYIP $LOGPATH $IPFILE
else
	exit_program "Public_IP KO"	

compare_last_publicIp_and_actual_publicIp