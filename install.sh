#!/bin/bash
tag="main"
zipfile="$tag.zip"
dir="kioskscripts-$tag/"
rm "$zipfile" && rm -r "$dir"
wget "https://github.com/dsentker/kioskscripts/archive/$tag.zip" && unzip "$zipfile" && cd "$dir" && ./prepare.sh
