#!/bin/bash
tag="main"
zipfile="$tag.zip"
dir="kioskscripts-$tag/"
kioskHome="$HOME/kiosk/"
rm "$zipfile" && rm -r "$dir" && rm -rf "$kioskHome"
mkdir "$kioskHome"
wget "https://github.com/dsentker/kioskscripts/archive/$tag.zip" && unzip "$zipfile" && mv -v "$dir"* "$kioskHome"* && cd "$kioskHome" && ./prepare.sh
