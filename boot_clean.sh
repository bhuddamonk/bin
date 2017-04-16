#!/bin/bash

# Script to clean out the boot partition
# For Debian based systems only

# Exit script on error
set -e

#turn debugging on and off
#set -x

echo -e "Disk on the /boot partition is $(df -h /boot | awk ' /[0-9]/ {print $5}' ) full.\n"
echo -e "The current kernel version in use is $(uname -r)\n\nlist of older kernels installed in the boot partition: "

echo -------------------------BEGIN------------------------------
#build array from old kernel list
karray=$((sudo dpkg --list 'linux-image*' | awk '{ if ($1=="ii") print $2}' | grep -v $(uname -r) ) )
echo ${karray[@]} | tr " " "\n"
echo ---------------------------END------------------------------
echo

#debug to check array contents
#echo "Array contains ${karray[@]}"

#prompt user to remove old kernels
echo 'Remove all inactive kernels from the boot partition? Y/n'
read answer

# loop through and remove all old unused kernels to free up space
if [ "$answer" == 'Y' ] || [ "$answer" == 'y' ]; then
    for i in "${karray[@]}"
    do
      sudo rm -f "/boot/$i"
      echo deleting: $i | tr " " "\n"
    done

    #Clean up any old kernel packages
    echo
    echo 'Cleaning out old kernel packages:'
      sudo apt-get autoremove
    echo
      echo -e "Disk on the /boot partition is now $(df -h /boot | awk ' /[0-9]/ {print $5}' ) full.\n"
else
    echo 'Exiting script. Try running 'sudo apt-get clean' instead.'
fi
