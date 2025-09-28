#!/bin/bash

#this script creates new accounts on the local system and generates a strong password for them.

#make sure the script is excuted with superuser privileges.
if [[ ${UID} -ne 0 ]]
then 
   echo "please run with sudo or as root"
   exit 1
fi 
 

#make sure the user provided at least one argument.
if [[ ${#} -eq 0 ]] 
then
   echo "please provide a username and (optional) a real name" 
   echo "Usage: ${0} USER_NAME [COMMENT]..."
   exit 1
fi 

#arguments
USER_NAME="${1}"
shift 
COMMENT="${@}"

#generate a password. 
PASSWORD=$(date +%s%N | sha256sum | head -c16)

#create user with the arguments provided.
useradd -c "${COMMENT}" -m ${USER_NAME} 

#check to see if the useradd command succeeded.
if [[ "${?}" -ne 0 ]]
then
   echo "Failed to create a new account"
   exit 1
fi 

#set the password.
echo ${PASSWORD} | passwd --stdin ${USER_NAME}
#check to see if the passwd command succeeded.
if [[ "${?}" -ne 0 ]] 
then 
   echo "Failed to set password"
   exit 1
fi

#force password change on first login.
passwd -e ${USER_NAME}

#Display username, password and the host where the account was created.
echo "Username: ${USER_NAME}"
echo "Password: ${PASSWORD}"
echo "Host: ${HOSTNAME}"
exit 0 
