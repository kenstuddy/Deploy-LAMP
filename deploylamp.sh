#!/bin/bash
if [ "$EUID" -ne 0 ]
then 
    echo "Please run this script as root."
    exit
fi
#We can run this script as root, but we do not want to put the username as root
until [[ $username != "" && $username != root ]]; do
read -p "Please enter your username: " username
done
#Add repository for PHP 7.2
sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update && sudo apt-get dist-upgrade -y
sudo ufw allow 80
sudo ufw allow 443
sudo apt-get install openssh-server apache2 apache2-utils mysql-server php7.2 php7.2-curl php7.2-cgi libapache2-mod-php php-mysql php7.2-dom php7.2-mbstring unzip -y
sudo apt-get install php7.2-xml php7.2-zip libxslt1.1 -y
sudo mysql_secure_installation
#Done with installing LAMP, now it is time to secure the server
sudo apt-get install fail2ban psad rkhunter chkrootkit -y
sudo groupadd admin
sudo usermod -a -G admin $username
sudo dpkg-statoverride --update --add root admin 4750 /bin/su
if grep -lir "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" "/etc/fstab"
then
    echo ""
else
    sudo su -c "echo 'tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0' >> /etc/fstab"
fi
if grep -lir "nospoof on" "/etc/host.conf"
then
    echo ""
else
    sudo su -c "echo 'nospoof on' >> /etc/host.conf"
fi
sudo find /var/www/html \( -type f -execdir chmod 644 {} \; \) \
                  -o \( -type d -execdir chmod 711 {} \; \)
sudo chown -R www-data:www-data /var/www/html
sudo a2enmod headers
sudo service apache2 restart
#sudo chkrootkit
#sudo rkhunter --update
#sudo rkhunter --propupd
#sudo rkhunter --check
#sudo apt-get install wapiti -y
#wapiti http://example.org -n 10 -b folder
sudo ufw enable
