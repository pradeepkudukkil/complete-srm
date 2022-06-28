# Script for Complete SRM in ubuntu and centos

What is SRM
==============

SRM (or Secure Remove) is a command line utility for Unix-like computer systems for secure file deletion. srm removes each specified file by overwriting, renaming, and truncating it before unlinking. This prevents other people from undeleting or recovering any information about the file from the command line.

By Using this script you can perform complete SRM for ubuntu and centos, mainly complete SRM is performed before server cancelation to avoid data leakage.

How script is working
==============

Before running the script you need to create a file named file-list.txt and specify the folder path for SRM.

example contents of file-list.txt

/backup<br>
/home<br>
/var/log<br>

Each folder scans the script for its sub-inner folders and files and finds out which is the largest file and folder based on the value given in the script(lines 58 and 69). If the script receives a large file, the SRM will run on separate screen, so each file will run on a separate screen. This way we can speed up the SRM task, please use big folder size as more than 1000MB in script, here I am using 1000MB, if you use only a small size, the number of SRM tasks on the screen is increases, which creates load, please Use the best limit for your use case.

Use the below steps to run Complete-SRM script.
------------------

1 copy script and create dependent file file-list.txt.

mkdir /root/complete-srm<br>
cd /root/complete-srm<br>
copy srm-latest.sh to /root/complete-srm folder<br>
create file file-list.txt and specify the folder path for SRM.<br>

2 Run srm-latest.sh from the newly created screen, Make sure you are on the root

screen -S Complete-srm<br>
sudo su -<br>
cd /root/complete-srm<br>
chmod +x srm-latest.sh<br>
./srm-latest.sh<br>

NOTE : DO NOT EXIT FROM THE SCRIPT UNTIL THE SCRIPT IS COMPLETE, YOU CAN DETACH THE SCREEN.

After that, please enter 'complete-srm' for initiating SRM<br>
You will receive detailed information about SRM every minute after starting SRM, an example is mentioned below<br>


![image](https://user-images.githubusercontent.com/88960052/176163701-c6649810-7d4f-4aac-842c-5a330ccc27be.png)


Finally, you will get the message 'SRM completed'
