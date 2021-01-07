#!/bin/bash
set -e

# lookup specific binaries
: "${BIN_7Z:=$(type -P 7z)}"
: "${BIN_XORRISO:=$(type -P xorriso)}"
: "${BIN_CPIO:=$(type -P gnucpio || type -P cpio)}"

# get directories
CURRENT_DIR="`pwd`"
DIST_DIR="$CURRENT_DIR/dist"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# get parameters
if [ "$1" = "force" ]; then
    rm -vR "$DIST_DIR"
    SSH_PUBLIC_KEY_FILE="$HOME/.ssh/id_rsa.pub"
    TARGET_ISO="`pwd`/ubuntu-20.04-netboot-amd64-unattended.iso"
else
    SSH_PUBLIC_KEY_FILE=${1:-"$HOME/.ssh/id_rsa.pub"}
    TARGET_ISO=${2:-"`pwd`/ubuntu-20.04-netboot-amd64-unattended.iso"}
fi

# check if ssh key exists
if [ ! -f "$SSH_PUBLIC_KEY_FILE" ]; then
    echo "Error: public SSH key $SSH_PUBLIC_KEY_FILE not found!"
    exit 1
fi

# create working dirs
TMP_DISC_DIR="`mktemp -d`"
TMP_INITRD_DIR="`mktemp -d`"

# download and extract netboot iso
SOURCE_ISO_URL="http://archive.ubuntu.com/ubuntu/dists/focal/main/installer-amd64/current/legacy-images/netboot/mini.iso"

if [ ! -d "$DIST_DIR" ]; then
    mkdir -p "$DIST_DIR"
fi

if [ ! -f "$DIST_DIR/netboot.iso" ]; then
    wget -4 "$SOURCE_ISO_URL" -O "$DIST_DIR/netboot.iso"
fi

"$BIN_7Z" x "$DIST_DIR//netboot.iso" "-o$TMP_DISC_DIR"

# get inputs
read -ep " please enter your hostname: " -i "tec-desktop" HOST_NAME
read -ep " please enter your preferred username: " -i "$( whoami)" USER_NAME
read -sp " please enter your preferred password: " PWD1
printf "\n"
read -sp " confirm your preferred password: " PWD2
printf "\n"

# check if the passwords match to prevent headaches
if [[ "$PWD1" != "$PWD2" ]]; then
    echo " your passwords do not match; please restart the script and try again"
    exit
else
    # generate the password hash
    PWD_HASH=$(echo $PWD1 | mkpasswd -s -m sha-512)
fi

PACKAGES=$(tr '\n' ' ' < $CURRENT_DIR/systems/$HOST_NAME/packages.txt)

# patch boot menu
cd "$TMP_DISC_DIR"
dos2unix "./isolinux.cfg"
patch -p1 -i "$SCRIPT_DIR/custom/boot-menu.patch"

# prepare assets
cd "$TMP_INITRD_DIR"
mkdir "./custom"

cp "$SCRIPT_DIR/custom/preseed.cfg" "./preseed.cfg"

# replace tokens
sed -i -e "/{{late-commands}}/{r $CURRENT_DIR/systems/$HOST_NAME/late_cmd.txt" -e 'd;}' ./preseed.cfg
sed -i "s@{{username}}@$USER_NAME@g" ./preseed.cfg
sed -i "s@{{hash}}@$PWD_HASH@g" ./preseed.cfg
sed -i "s@{{host}}@$HOST_NAME@g" ./preseed.cfg
sed -i "s@{{packages}}@$PACKAGES@g" ./preseed.cfg

cp "$SSH_PUBLIC_KEY_FILE" "./custom/userkey.pub"
cp "$SCRIPT_DIR/custom/ssh-host-keygen.service" "./custom/ssh-host-keygen.service"

# TEC 
echo "copying from $SCRIPT_DIR"
cp "$SCRIPT_DIR/custom/.bash_aliases" "./custom/.bash_aliases"
dos2unix "./custom/.bash_aliases"

cp "$SCRIPT_DIR/custom/fstab" "./custom/fstab"
dos2unix "./custom/fstab"

cp "$SCRIPT_DIR/custom/init.sh" "./custom/init.sh"
if [ -f "$CURRENT_DIR/systems/$HOST_NAME/init.sh" ]; then
    cat $CURRENT_DIR/systems/$HOST_NAME/init.sh >> ./custom/init.sh 
fi
dos2unix "./custom/init.sh"

# append assets to initrd image
cd "$TMP_INITRD_DIR"
cat "$TMP_DISC_DIR/initrd.gz" | gzip -d > "./initrd"
echo "./preseed.cfg" | fakeroot "$BIN_CPIO" -o -H newc -A -F "./initrd"
find "./custom" | fakeroot "$BIN_CPIO" -o -H newc -A -F "./initrd"
cat "./initrd" | gzip -9c > "$TMP_DISC_DIR/initrd.gz"

# build iso
cd "$TMP_DISC_DIR"
rm -r '[BOOT]'
"$BIN_XORRISO" -as mkisofs -r -V "ubuntu__20_$HOST_NAME_unattended" -J -b isolinux.bin -c boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -input-charset utf-8 -isohybrid-mbr "$SCRIPT_DIR/custom/isohdpfx.bin" -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -o "$TARGET_ISO" ./

# go back to initial directory
cd "$CURRENT_DIR"

mv $TARGET_ISO "./$HOST_NAME.iso"

# delete all temporary directories
rm -r "$TMP_DISC_DIR"
rm -r "$TMP_INITRD_DIR"

# done
echo "Next steps: install system, login via $USER_NAME, enjoy!"
