#!/bin/bash
#this script creates accounts on the local system

#make sure it's executed with root privileges.
if [[ "${UID}" -ne 0 ]]
then 
  echo "permission denied, you need superuser(root) privileges"
  exit 1
fi

#get the username.
read -p 'enter the username for your account: ' USER_NAME
#get the name of the person using the account.
read -p 'enter the name of the person this account is for: ' COMMENT
#get the initial password.
read -p 'enter your password: ' PASSWORD 
#create new user with the input.
useradd -c "${COMMENT}" -m "${USER_NAME}"
#check if the useradd command succeeded.
if [[ "${?}" -ne 0 ]]
then 
  echo "failed to add user"
  exit 1
fi
#set the password
echo ${PASSWORD} | passwd --stdin ${USER_NAME}
#check if the passwd command succeeded.
if [[ "${?}" -ne 0 ]]
then 
  echo 'failed to set password'
  exit 1
fi 
#display the username, password, and the host where the user was created. 
echo "account created username: "${USER_NAME}" password: "${PASSWORD}" host: "${HOSTNAME}" "
#force password change on first login.
passwd -e ${USER_NAME}


