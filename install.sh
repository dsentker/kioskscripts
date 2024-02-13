#!/bin/bash
tag="main"
zipfile="https://github.com/dsentker/kioskscripts/archive/$tag.zip"
wget $zipfile && unzip "$tag.zip" && cd "kioskscripts-$tag/" && ./setup.sh
