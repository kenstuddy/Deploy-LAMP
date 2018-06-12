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
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y
#Add repository for Node.js LTS 6.x
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get update && sudo apt-get dist-upgrade -y
sudo ufw allow 80
sudo ufw allow 443
sudo apt-get install nodejs p7zip-full openssh-server apache2 apache2-utils mysql-server php7.2 php7.2-curl php7.2-cgi php7.2-gd libapache2-mod-php7.2 php-mysql php7.2-dom php7.2-mbstring unzip php7.2-xml php7.2-zip libxslt1.1 php7.2-sqlite3 -y
sudo apt-get install libapache2-mod-php5.6 php5.6 php5.6-curl php5.6-cgi php5.6-dom php5.6-mbstring php5.6-xml php5.6-zip php5.6-gd -y
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
sudo ufw enable
sudo a2enmod headers
sudo service apache2 restart

#To enable php 7.2
sudo a2dismod php5.6
sudo a2enmod php7.2
sudo service apache2 restart
sudo update-alternatives --set php /usr/bin/php7.2
sudo update-alternatives --set phar /usr/bin/phar7.2
sudo update-alternatives --set phar.phar /usr/bin/phar.phar7.2
#To enable php 5.6
#sudo a2dismod php7.2
#sudo a2enmod php5.6
#sudo service apache2 restart
#sudo update-alternatives --set php /usr/bin/php5.6
#sudo update-alternatives --set phar /usr/bin/phar5.6
#sudo update-alternatives --set phar.phar /usr/bin/phar.phar5.6 
