#!/bin/bash

# installing SRM and screen in centos/ubuntu
apt-get install secure-delete -y  > /dev/null 2>&1

yum install wget -y  > /dev/null 2>&1
#wget http://downloads.sourceforge.net/project/srm/1.2.15/srm-1.2.15.tar.gz > /dev/null 2>&1
wget https://github.com/pradeepkudukkil/complete-srm/blob/main/srm-1.2.15.tar.gz > /dev/null 2>&1
yum install gcc -y > /dev/null 2>&1
tar -xvzf srm-1.2.15.tar.gz > /dev/null 2>&1
rm -rf srm-1.2.15.tar.gz
cd srm-1.2.15/
./configure > /dev/null 2>&1
yum install make -y > /dev/null 2>&1
make > /dev/null 2>&1
make install  > /dev/null 2>&1
cd ../

apt-get install screen -y > /dev/null 2>&1
yum install screen -y > /dev/null 2>&1

echo -e "=================== \n\e[1;31mAlert \e[0m : 	 \e[1;31mThis is a Complete SRM script\e[0m\n===================\n"
echo -e "*   Hope you created file-list.txt that contains files path which needs to SRM\n"
echo -e "*   Enter \e[1;31mcomplete-srm\e[0m for initiating SRM in this server"
read user_input
echo -e "\nCreating separate SRM for the below-given files and folders.\n"
which srm  > /dev/null 2>&1
srm_install=$?
if [ $srm_install -eq 0 ]
then
  if [ $user_input == 'complete-srm' ]
  then
    
    curent_screen=$(/usr/bin/screen -ls | grep Detached | wc -l)
    total_disk_new=0
    srm_name=1
    > innerfolders.txt
    > srm_log.txt
    > wrong_folders_list.txt
    > innerfolders.txt
    > correct_list.txt
    #Reading each line from the file file-list.txt
    while read mainfolder; do
    du -sh $mainfolder > /dev/null 2>&1
    file_existence_check=$?

    #Run the below code, if the line exists in the server
    if [ $file_existence_check -eq 0 ];then
        echo $mainfolder >> correct_list.txt
        total_disk=$(du -sm $mainfolder | awk '{print $1}')
        total_disk_new=$((total_disk_new+total_disk))

        if [ -d $mainfolder ];then
            size=$(du -sm $mainfolder | awk '{print $1}')
            #echo $size

        #Run the below code, If the line is directory and size greater than the given value
            if [ "$size" -gt "1000" ];then

            #Run SRM if the size of the inner files/inner folders is greater than the given value
                find $mainfolder  > innerfolders.txt
                while read innerfolder;do

            du -sh $innerfolder > /dev/null 2>&1
            inner_file_existence_check=$?
            if [ $inner_file_existence_check -eq 0 ];then

                      innersize=$(du -sm $innerfolder | awk '{print $1}')
                      if [ "$innersize" -gt "1000" ];then
                              #echo $innerfolder
                              echo $innerfolder >> srm_log.txt
                              du -sh $innerfolder
                              /usr/bin/screen -dmS $srm_name srm -rvf $innerfolder
                              echo $srm_name >> srm_log.txt
                              srm_name=$((srm_name+1))
                      fi
            fi
                done < innerfolders.txt

        #Run the below code, If the line is a directory and the size is less than the given value
            else
                #echo $mainfolder
                echo $mainfolder >> srm_log.txt
                du -sh $mainfolder
                /usr/bin/screen -dmS $srm_name srm -rvf $mainfolder
                echo $srm_name >> srm_log.txt
                srm_name=$((srm_name+1))
            fi

        #Run the below code, If the line is a file
        else
            #echo $mainfolder
            echo $mainfolder >> srm_log.txt
            du -sh $mainfolder
            /usr/bin/screen -dmS $srm_name srm -rvf $mainfolder
            echo $srm_name >> srm_log.txt
            srm_name=$((srm_name+1))
        fi
    else

        #Run the below code, if the line does not exist in the server
        echo $mainfolder >> wrong_folders_list.txt
    fi
    done < file-list.txt

    srm_name=$((srm_name-1))

    pending_screen=$(/usr/bin/screen -ls | grep Detached | wc -l)
    pending_screen=$((pending_screen-curent_screen))

    #Checking SRM status, and print
    while [ $pending_screen -gt 0 ]
    do
      pending_disk_new=0
      while read pending_file; do

          du -sh $pending_file > /dev/null 2>&1
          pending_file_existence_check=$?
          if [ $pending_file_existence_check -eq 0 ];then
                  pending_disk=$(du -sm $pending_file | awk '{print $1}')
                  pending_disk_new=$((pending_disk_new+pending_disk))
          fi
      done < correct_list.txt
      pending_screen=$(/usr/bin/screen -ls | grep Detached | wc -l)
      pending_screen=$((pending_screen-curent_screen))
      echo -e  "\nSRM status     $(date '+%Y-%m-%d %H:%M:%S') \n"
      echo -e "=================== \nTotal Disk to clean(SRM):	   $total_disk_new MB\nTotal Screen			   $srm_name \n\n\n"
      echo -e "Pending Disk to clean(SRM):        $pending_disk_new MB\nPending Screen    	  	   $pending_screen \n===================\n"
      

      #Checking the SRM completed or not
      if [ "$pending_screen" -gt "0" ];then
          echo -e "		\e[1;31mPlease wait for 1 more minutes for next SRM update\e[0m\n===================\n"
      else
        echo -e "+++++++++++++++++++ \e[1;31m SRM completed\e[0m +++++++++++++++++++"
        srm -rvf innerfolders.txt srm_log.txt file-list.txt wrong_folders_list.txt correct_list.txt > /dev/null 2>&1
        history -c
      fi
      sleep 60  
  done

  fi
else  
  echo -e "srm is not installed, please check.. " 
fi
