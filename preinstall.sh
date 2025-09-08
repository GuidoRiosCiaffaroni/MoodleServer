sudo apt update -y && sudo apt install -y dos2unix

dos2unix install.sh
dos2unix apache_moodle.sh


chmod +x install.sh
chmod +x apache_moodle.sh

sudo ./install.sh
sudo ./apache_moodle.sh

