#!/bin/bash
#this script disables, deletes, and/or archives users on the local system.

ARCHIVE_DIR='/archive'

usage() {
   
   echo "Usage: ${0} [-dra] USER [USERN]..." >&2
   echo 'disable a local linux account.' >&2
   echo '   -d delets accounts instead of disabling them.' >&2
   echo '   -r removes the account(s) home directory.' >&2
   echo '   -a creates an archive of the home directory associated with the account(s).' >&2
   exit 1
}

#script must be excuted with super user privileges.

if [[ "${UID}" -ne 0 ]]
then
   echo 'Please run with sudo or as root ' >&2
   exit 1
fi

#parse options

while getopts dra OPTION
do 
   case ${OPTION} in 
   d) DELETE_USER='true' ;;
   r) REMOVE_OPTION='-r' ;;
   a) ARCHIVE='true' ;;
   ?) usage ;;
   esac
done 

shift "$(( OPTIND - 1 ))"

#must provide at least one argument.
if [[ "${#}" -lt 1 ]]
then 
   usage 
fi 

#loop through all the arguments(usernames)

for USERNAME in "${@}"
do 
   echo "Processing user: ${USERNAME}"
   
   #UID of the account must be at least 1000.

   USERID=$(id -u ${USERNAME})
   if [[ "${USERID}" -lt 1000 ]]
   then 
      echo "Can't remove the ${USERNAME} account with UID ${USERID}." >&2
      exit 1
   fi 
   
   #create archive if requested.
   
   if [[ "${ARCHIVE}" = 'true' ]] 
   then 
      if [[ ! -d "${ARCHIVE_DIR}" ]]
      then 
         echo "creating ${ARCHIVE_DIR} directory"
         mkdir -p ${ARCHIVE_DIR} 
         if [[ "${?}" -ne 0 ]]
         then 
            echo 'Failed to create archive directory' >&2
            exit 1
         fi
      fi
        
      #archive the user's home directory into the ARCHIVE_DIR
      HOMEDIR="/home/${USERNAME}"
      ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"
      if [[ -d "${HOMEDIR}" ]]
      then 
        tar -zcf ${ARCHIVE_FILE} ${HOMEDIR} &> /dev/null
        if [[ "${?}" -ne 0 ]]
        then 
           echo "Failed to create ${ARCHIVE_FILE}." >&2
           exit 1
        fi
      else 
         echo "${HOMEDIR} does not exist or is not a directory." >&2
         exit 1
      fi
   fi
    
   if [[ "${DELETE_USER}" = 'true' ]]
   then
     userdel ${REMOVE_OPTION} ${USERNAME}
   
     if [[ "${?}" -ne 0 ]]
     then 
       echo "Failed to delete the account ${USERNAME}" >&2
       exit 1
     fi
     echo "The account ${USERNAME} was deleted"
   else 
      chage -E 0 ${USERNAME}
      if [[ "${?}" -ne 0 ]]
      then 
        echo "Failed to disable the account ${USERNAME}" >&2
        exit 1
      fi   
      echo "The account ${USERNAME} was disabled."
   fi
done 
exit 0  

      



