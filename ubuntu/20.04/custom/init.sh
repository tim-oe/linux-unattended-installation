#!/bin/bash

# gnome settings
dconf write /org/gtk/settings/file-chooser/show-hidden "true"
dconf write /org/gnome/terminal/legacy/theme-variant "'dark'"
dconf write /org/gnome/desktop/background/picture-uri "''"
dconf write /org/gnome/desktop/background/primary-color "'#000000'"
