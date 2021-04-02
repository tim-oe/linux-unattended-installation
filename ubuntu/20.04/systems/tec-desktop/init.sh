# power settings stop auto suspend
dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout "0"

#favorites
dconf write /org/gnome/shell/favorite-apps "['firefox.desktop','virt-manager.desktop','org.gnome.Terminal.desktop','org.gnome.Nautilus.desktop','yelp.desktop']"

# bridged Networ
# try to read nic
NIC=$(nmcli con show --active | sed -En 's/.*ethernet\s+([[:alnum:]]*)/\1/p')
read -ep "nic device name: " -i "$NIC" NIC

sudo nmcli con add ifname br0 type bridge con-name br0
sudo nmcli con add type bridge-slave ifname $NIC master br0

#warning could disconnect remote connection 
sudo sh -c 'nmcli con down "Wired connection 1" && nmcli con up br0' 

echo '<network><name>br0</name><forward mode="bridge"/><bridge name="br0" /></network>' > ./bridge.xml
sudo virsh net-define ./bridge.xml
sudo virsh net-start br0
sudo virsh net-autostart br0

