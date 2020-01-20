#!/bin/bash
if [[ "$EUID" != 0 ]]
then 
    echo "Please run this script as root."
    exit
fi
#We can run this script as root, but we do not want to put the username as root
until [[ $username != "" && $username != root ]]; do
    echo "Please enter your username: "
    read -s username
done
#Add repository for PHP 7.x
sudo add-apt-repository ppa:ondrej/php -y
#We used to be able to have sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y however this syntax is no longer valid in Ubuntu 18.04
export LC_ALL=C.UTF-8
#Add repository for Node.js LTS 10.x
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get update && sudo apt-get dist-upgrade -y
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 22
sudo apt-get install uptimed nodejs p7zip-full openssh-server apache2 apache2-utils mysql-server php7.4 php7.4-curl php7.4-cgi php7.4-gd libapache2-mod-php7.4 php-mysql php7.4-dom php7.4-mbstring unzip php7.4-xml php7.4-zip libxslt1.1 php7.4-sqlite3 webp php-imagick -y
sudo mysql_secure_installation
#Done with installing LAMP, now it is time to secure the server
sudo apt-get install fail2ban psad rkhunter chkrootkit -y
sudo groupadd admin
sudo usermod -a -G admin $username
sudo dpkg-statoverride --update --add root admin 4750 /bin/su
if ! grep -lir "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" "/etc/fstab"
then
    sudo su -c "echo 'tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0' >> /etc/fstab"
fi
sudo find /var/www/html \( -type f -execdir chmod 644 {} \; \) \
                  -o \( -type d -execdir chmod 711 {} \; \)
sudo chown -R www-data:www-data /var/www/html
sudo ufw enable
sudo a2enmod headers
sudo service apache2 restart

#To enable php 7.4
sudo a2dismod php7.2
sudo a2dismod php7.3
sudo a2enmod php7.4
sudo service apache2 restart
sudo update-alternatives --set php /usr/bin/php7.4
sudo update-alternatives --set phar /usr/bin/phar7.4
sudo update-alternatives --set phar.phar /usr/bin/phar.phar7.4
#To enable php 7.3
#sudo a2dismod php7.2
#sudo a2dismod php7.4
#sudo a2enmod php7.3
#sudo service apache2 restart
#sudo update-alternatives --set php /usr/bin/php7.3
#sudo update-alternatives --set phar /usr/bin/phar7.3
#sudo update-alternatives --set phar.phar /usr/bin/phar.phar7.3
#To enable php 7.2
#sudo a2dismod php7.3
#sudo a2dismod php7.4
#sudo a2enmod php7.2
#sudo service apache2 restart
#sudo update-alternatives --set php /usr/bin/php7.2
#sudo update-alternatives --set phar /usr/bin/phar7.2
#sudo update-alternatives --set phar.phar /usr/bin/phar.phar7.2 
