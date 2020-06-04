#!/bin/bash
 
function update(){

read -p "[*]Would you like to update your system y/n: " user_var1
if [ "$user_var1" == "y" ]; then
    yum update
    yum install samba-client samba-common samba
else
    yum install samaba-client samba-common samba
fi
}

function copy_files(){

echo "[*] backup the original smb.conf file";
mv /etc/samba/smb.conf /etc/samba/smb.conf.backup
echo "[*] copying your smb.conf file[*]";
mv smb.conf /etc/samba/

}

function open_shares_and_selinux_conf(){
a=0
echo "[*]BE CAREFULL IT IS A CASE SENSITIVE![*]";
read -p "[*] How many share you would like to open 1-10: " user_input_num
for ((i=user_input_num; i>=1; i--))
do
	echo "[*]Share will be opened at /etc/samba folder.[*]";
	read -p "[*]Enter the name of the share: " user_input_share
	mkdir /etc/samba/$user_input_share
	ls /etc/samba
	chcon -t samba_share_t /etc/samba/$user_input_share
done
}

function disable_selinux_and_restart_services(){

firewall-cmd --permanent --add-service=samba
firewall-cmd --reload
setenforce 0
systemctl enable smb.service
systemctl enable nmb.service
systemctl restart smb.service
systemctl restart nmb.service

}

function samba_users(){

read -p "[*]Please enter the new group name for samba users: " user_input_group
groupadd $user_input_group
read -p "[*]Please enter the name of the user who will be using samba: " user_input_user
usermod -a -G $user_input_group $user_input_user
echo "[*] Create an smb password for the user [*]"
smbpassword -a $user_input_user
systemctl restart smb.service
systemctl restart nmb.service
}

#Make sure only root user can run that.
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as a root" 1>&2
	exit 1
else
	update
	copy_files
	open_shares_and_selinux_conf
	disable_selinux_and_restart_services
	samba_users
fi
