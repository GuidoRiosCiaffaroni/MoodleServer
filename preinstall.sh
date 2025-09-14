#

apt-get update
apt-get upgrade -y

chmod +x 00_install_app.sh
chmod +x 01_install_apache2.sh
chmod +x 02_install_php.sh
#chmod +x 03_install_mysql.sh
#chmod +x 03_install_mariadb.sh

sudo ./00_install_app.sh
sudo ./01_install_apache2.sh
sudo ./02_install_php.sh
#sudo ./03_install_mysql.sh
#sudo ./03_install_mariadb.sh
