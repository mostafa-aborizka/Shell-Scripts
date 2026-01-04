#!/bin/bash
#This script allows the user to execute a command on every server on the servers file or a file they provide.

SERVER_LIST='/vagrant/servers'
SSH_OPTIONS='-o ConnectTimeout=2'

usage(){
  echo "Usage: ${0} [-nsv] [-f FILE] COMMAND" >&2
  echo 'Executes COMMAND as a single command on every server.' >&2
  echo "  -f FILE Uses FILE for the list of servers. Default ${SERVER_LIST}" >&2
  echo '  -n Dry mode run. Displays the COMMAND that would have been executed and exit' >&2
  echo '  -s Executes the COMMAND using sudo on the remote server.' >&2
  echo '  -v Verbose mode. Displays the server name before executing COMMAND' >&2
  exit 1
} 

#make sure the script is not being executed with superuser
if [[ "${UID}" -eq 0 ]]
then 
  echo 'Do not execute this script as root. use -s instead' >&2
  usage 
fi

#parse options 
while getopts f:nsv OPTION
do 
  case ${OPTION} in 
    f) SERVER_LIST="${OPTARG}" ;;
    n) DRY_RUN='true' ;;
    s) SUDO='sudo' ;;
    v) VERBOSE='true' ;;
    ?) usage 
  esac 
done

#Remove the options 
shift "$(( OPTIND -1 ))"

#make sure the user supplied a command
if [[ "${#}" -lt 1 ]]
then 
  usage
fi 

COMMAND="${@}"

#make sure the server list file exists
if [[ ! -e "${SERVER_LIST}" ]]
then 
  echo "Cannot open server list file :${SERVER_LIST}" >&2
  exit 1
fi 

EXIT_STATUS='0'

#loop through the servers
for SERVER in $(cat ${SERVER_LIST})
do 
  if [[ "${VERBOSE}" = 'true' ]]
  then 
    echo "${SERVER}"
  fi
  SSH_COMMAND="ssh ${SSH_OPTIONS} ${SERVER} ${SUDO} ${COMMAND}"  
  if [[ "${DRY_RUN}" = 'true' ]]
  then 
    echo "DRY RUN : ${SSH_COMMAND}"
  else 
    ${SSH_COMMAND}
    SSH_EXIT_STATUS="${?}"
    if [[ "${SSH_EXIT_STATUS}" -ne 0 ]]
    then 
      echo "Execution on ${SERVER} failed." >&2
      EXIT_STATUS=${SSH_EXIT_STATUS}
    fi 
  fi 
done 
exit ${EXIT_STATUS}

 
















  
    




























  






















