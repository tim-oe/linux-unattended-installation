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