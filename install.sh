#!/bin/bash

# Check if the current directory is not equal to $HOME
if [ "$PWD" != "$HOME" ]; then
    echo "Install only in your home directory ($HOME). Stopping installer..."
    exit 1
fi

tag="main"
zipfile="$tag.zip"
dir="kioskscripts-$tag/"
kioskHome="$HOME/kiosk/"
rm "$zipfile" && rm -r "$dir" && rm -rf "$kioskHome"
mkdir "$kioskHome"
wget -q "https://github.com/dsentker/kioskscripts/archive/$tag.zip"
unzip "$zipfile"
mv -v "$dir"* "$kioskHome" && rm -rf "$dir" && rm -rf "$HOME/c.log"
clear
cd "$kioskHome" || exit 1

if [[ "$1" == "--q" ]]; then
  ./prepare.sh --q # quiet mode, no interaction
else
  ./prepare.sh
fi
