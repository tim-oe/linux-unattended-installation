#!/bin/bash

# gnome settings run if installed
if [ -x "$(command -v dconf)" ]; then
    dconf write /org/gtk/settings/file-chooser/show-hidden "true"
    dconf write /org/gnome/terminal/legacy/theme-variant "'dark'"
    dconf write /org/gnome/desktop/background/picture-uri "''"
    dconf write /org/gnome/desktop/background/primary-color "'#000000'"
else
    echo "gnome not installed"
fi    
