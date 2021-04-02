#https://docs.docker.com/engine/install/ubuntu/
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose

#this did work in late command section
sudo snap install shotcut --classic

# install shotcut
dconf write /org/gnome/shell/favorite-apps "['firefox.desktop','vlc.desktop','shotcut_shotcut.desktop','org.gnome.Terminal.desktop','org.gnome.Nautilus.desktop','yelp.desktop']"

sudo mkdir -p /mnt/stuff

sudo bash -c 'printf "%s\n" "" "//tec-nas/stuff /mnt/stuff cifs credentials=/home/tcronin/.smbcreds,uid=tcronin,gid=tcronin 0 0" >> /etc/fstab'

read -ep " username: " USER_NAME
read -ep " password: " PWD

printf "%s\n" "username=$USER_NAME" "password=$PWD" "domain=workgroup" >> .smbcreds
chmod 600 .smbcreds

sudo mount -a

ln -s /mnt/stuff Downloads/stuff